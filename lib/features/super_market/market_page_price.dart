import 'package:breezefood/core/component/bottom_cart_action.dart';
import 'package:breezefood/core/component/have_order.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/presentation/cubit/market_details_cubit.dart';
import 'package:breezefood/features/super_market/supermarket_add_order_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../profile/presentation/widget/custom_appbar_profile.dart';

class MarketPagePrice extends StatelessWidget {
  final int marketId;
  final String title;
  final OrderInfo? haveOrder; // ✅ جديد
  const MarketPagePrice({
    this.haveOrder,
    super.key,
    required this.marketId,
    required this.title,
  });

  int _cartCount(dynamic cart) {
    if (cart == null) return 0;

    try {
      final items = (cart as dynamic).items;
      if (items is List) return items.length;
    } catch (_) {}

    try {
      final items = (cart as dynamic).data;
      if (items is List) return items.length;
    } catch (_) {}

    try {
      final c = (cart as dynamic).count;
      if (c is num) return c.toInt();
      return int.tryParse(c.toString()) ?? 0;
    } catch (_) {}

    try {
      final c = (cart as dynamic).itemsCount;
      if (c is num) return c.toInt();
      return int.tryParse(c.toString()) ?? 0;
    } catch (_) {}

    return 0;
  }

  num _cartTotal(dynamic cart) {
    if (cart == null) return 0;

    try {
      final v = (cart as dynamic).total;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    try {
      final v = (cart as dynamic).totalPrice;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    try {
      final v = (cart as dynamic).grandTotal;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    try {
      final v = (cart as dynamic).subTotal;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MarketDetailsCubit(
            repo: getIt<SuperMarketRepo>(),
            marketId: marketId,
          )..load(),
        ),
        BlocProvider(create: (_) => getIt<CartCubit>()..loadCart()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MarketDetailsCubit, MarketDetailsState>(
            listener: (context, state) {
              if (state.loading || state.loadingItems) {
                EasyLoading.show(status: "Loading...".tr());
              } else {
                EasyLoading.dismiss();
              }

              if (state.error != null) {
                EasyLoading.dismiss();
                EasyLoading.showError(state.error!);
              }
            },
          ),
          BlocListener<CartCubit, CartState>(
            listener: (context, state) {
              state.whenOrNull(
                loading: () => EasyLoading.show(status: "Adding...".tr()),
                addedSuccess: (msg) {
                  EasyLoading.dismiss();
                  EasyLoading.showSuccess(
                    msg.isEmpty ? "added_success".tr() : msg,
                  );
                  context.read<CartCubit>().loadCart();
                },
                error: (msg) {
                  EasyLoading.dismiss();
                  EasyLoading.showError(
                    msg.isEmpty ? "something_wrong".tr() : msg,
                  );
                },
              );
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(110.h),
            child: CustomAppbarProfile(
              title: title,
              icon: Icons.arrow_back_ios,
              ontap: () => Navigator.pop(context),
              backgroundcolor: Colors.transparent,
            ),
          ),

          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: BlocBuilder<MarketDetailsCubit, MarketDetailsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null) {
                      return Center(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Categories
                        SizedBox(
                          height: 44.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.categories.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (context, i) {
                              final c = state.categories[i];
                              final selected = c.id == state.selectedCategoryId;

                              return InkWell(
                                onTap: () => context
                                    .read<MarketDetailsCubit>()
                                    .selectCategory(c.id),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF1C1C1C),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Text(
                                    c.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 12.h),

                        /// Items Grid
                        Expanded(
                          child: state.loadingItems
                              ? const Center(child: CircularProgressIndicator())
                              : GridView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    // vertical: 8.h,
                                  ),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: state.items.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing:
                                            16.w, // مسافة أفقية واضحة
                                        mainAxisSpacing:
                                            20.h, // 👈 مسافة عمودية متل الصورة
                                        mainAxisExtent:
                                            230.h, // 👈 ارتفاع ثابت للكرت
                                      ),
                                  itemBuilder: (context, index) {
                                    final it = state.items[index];

                                    final titleTxt = context.pick(
                                      ar: it.nameAr,
                                      en: it.nameEn,
                                    );

                                    final descTxt = context.pick(
                                      ar: it.descriptionAr,
                                      en: it.descriptionEn,
                                    );

                                    final imgUrl =
                                        UrlHelper.toFullUrl(it.image) ?? "";

                                    return InkWell(
                                      onTap: !it.isAvailable
                                          ? () => EasyLoading.showInfo(
                                              "Not available".tr(),
                                            )
                                          : () async {
                                              final res =
                                                  await showSupermarketAddOrderDialog(
                                                    context,
                                                    title: titleTxt,
                                                    price: it.basePrice,
                                                    imagePath: imgUrl.isNotEmpty
                                                        ? imgUrl
                                                        : "assets/images/bread.png",
                                                  );

                                              if (res == null) return;

                                              context.read<CartCubit>().add(
                                                AddToCartRequest(
                                                  restaurantId: marketId,
                                                  menuItemId: it.id,
                                                  quantity: res.quantity,
                                                  specialNotes: res.notes,
                                                ),
                                              );
                                            },
                                      child: ProductCard(
                                        product: Product(
                                          title: titleTxt,
                                          desc: descTxt,
                                          price: context.syp(
                                            it.basePrice,
                                            decimals: 0,
                                          ),
                                          image: imgUrl.isNotEmpty
                                              ? imgUrl
                                              : "assets/images/bread.png",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 16.h,
                child: SafeArea(
                  top: false,
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, st) {
                      int count = 0;
                      num total = 0;

                      st.maybeWhen(
                        cartLoaded: (cart, updatingIds, toast, isRefreshing) {
                          count = _cartCount(cart);
                          total = _cartTotal(cart);
                        },
                        orElse: () {},
                      );

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16.h,
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: BottomCartAction(
                              haveOrder: haveOrder,
                              usePrimaryButton:
                                  false, // لأنه هون كنت تستعمل CustomButtonOrder
                              showCountAndTotal: true,
                              onViewCart: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value: context.read<CartCubit>(),
                                        ),
                                        BlocProvider(
                                          create: (_) =>
                                              getIt<OrderFlowCubit>(),
                                        ),
                                      ],
                                      child: const RequestOrderScreen(),
                                    ),
                                  ),
                                );

                                if (context.mounted)
                                  context.read<CartCubit>().loadCart();
                              },
                            ),
                          ),
                        ),
                      );

                      // ✅ 2) إذا ما في سلة وفي haveOrder: Track Order
                      if (haveOrder != null) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: CustomButtonOrder(
                            title: "home.your_order"
                                .tr(), // أو "home.track_order".tr()
                            onPressed: () =>
                                openHaveOrderTracking(context, haveOrder!.id),
                          ),
                        );
                      }

                      // ✅ 3) لا سلة ولا haveOrder: لا تعرض شي
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// Product Card
/// =======================================================

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Image
        ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: SizedBox(
            width: double.infinity,
            height: 170.h, // 👈 أكبر شوي متل الصورة
            child: product.isNetworkImage
                ? Image.network(product.image, fit: BoxFit.cover)
                : Image.asset(product.image, fit: BoxFit.cover),
          ),
        ),

        SizedBox(height: 10.h),

        /// Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        /// Price
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            product.price,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// =======================================================
/// Product Model
/// =======================================================

class Product {
  final String title;
  final String price;
  final String image;
  final String desc;

  Product({
    required this.title,
    required this.desc,
    required this.price,
    required this.image,
  });

  bool get isNetworkImage => image.startsWith("http");
}

import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/popular_grid_Page.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_sheet.dart'; // showAddOrderDialog
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart'; // MenuExtra (الموحد)
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:like_button/like_button.dart';

/// --------------------------------------------------------------
/// عنوان القسم "Most Popular"
/// --------------------------------------------------------------
class CustomTitleSection extends StatelessWidget {
  final String title;
  final String? all;
  final IconData? icon;
  final VoidCallback? ontap;

  const CustomTitleSection({
    required this.title,
    this.all,
    this.icon,
    this.ontap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                ? 'Cairo'
                : 'Inter',
          ),
        ),
        if (all != null && ontap != null)
          GestureDetector(
            onTap: ontap,
            child: Row(
              children: [
                Text(
                  all!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface,
                    fontFamily:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(icon, size: 14.sp, color: colorScheme.onSurface),
              ],
            ),
          ),
      ],
    );
  }
}

/// --------------------------------------------------------------
/// Section: Most Popular horizontal list (HOME)
//  ✅ MenuItemModel
/// --------------------------------------------------------------
class MostPopularSection extends StatelessWidget {
  final List<MenuItemModel> items;
  final int? restaurantId;
  final bool isRestaurantOpen; // ✅ جديد

  const MostPopularSection({
    super.key,
    required this.items,
    this.restaurantId,
    required this.isRestaurantOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final gap = 8.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;

    final count = items.length;
    double containerWidth = switch (count) {
      0 => 0,
      1 => cardWidth + 4,
      2 => (2 * cardWidth) + gap + 4,
      _ => MediaQuery.of(context).size.width - 20,
    };

    containerWidth = containerWidth.clamp(
      0.0,
      MediaQuery.of(context).size.width - 20,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomTitleSection(
            title: "most_popular".tr(),
            all: "common.all".tr().tr(),
            icon: Icons.arrow_forward_ios_outlined,
            ontap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PopularGridPage(
                    items: items,
                    restaurantId: restaurantId,
                    isRestaurantOpen: isRestaurantOpen, // ✅ مهم
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220.h,
          // width: containerWidth,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            physics: count <= 2
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];

              final title = item.nameAr.isNotEmpty ? item.nameAr : item.nameEn;

              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 16.w : 0, // 🔥 أول عنصر فقط
                  end: index == count - 1 ? 16.w : gap,
                ),
                child: SizedBox(
                  width: 142.w,

                  child: GestureDetector(
                    onTap: () async {
                      final menuItemId = item.id;
                      final resolvedRestaurantId = restaurantId ?? 0;

                      if (resolvedRestaurantId == 0 || menuItemId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("لا يمكن تحديد المطعم أو الوجبة"),
                          ),
                        );
                        return;
                      }

                      await showAddOrderDialog(
                        context,
                        restaurantId: resolvedRestaurantId,
                        menuItemId: menuItemId,
                        title: title,
                        price: (item.priceAfter > 0
                            ? item.priceAfter
                            : item.priceBefore),
                        oldPrice: item.priceBefore,
                        imagePathOrUrl:
                            item.primaryImage?.imageUrl ??
                            "assets/images/shawarma_box.png",
                        description: "",
                        extraMeals: const <MenuExtra>[],
                        isRestaurantOpen: isRestaurantOpen,
                        extraGroups: <ExtraGrouped>[], // ✅ المصدر الوحيد
                      );

                      if (context.mounted) context.read<CartCubit>().loadCart();
                    },
                    child: PopularItemCard(
                      item: item,
                      isRestaurantOpen: isRestaurantOpen, // ✅ نفس الفلاج
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// --------------------------------------------------------------
/// Card: Popular Item (HOME) + Favorite Toggle
/// ✅ MenuItemModel
/// --------------------------------------------------------------
class PopularItemCard extends StatefulWidget {
  final MenuItemModel item;
  final bool isRestaurantOpen;

  const PopularItemCard({
    super.key,
    required this.item,
    required this.isRestaurantOpen,
  });

  @override
  State<PopularItemCard> createState() => _PopularItemCardState();
}

class _PopularItemCardState extends State<PopularItemCard> {
  bool _isFavorite = false; // ✅ no late
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.item.isFavorite;
  }

  @override
  void didUpdateWidget(covariant PopularItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.isFavorite != widget.item.isFavorite) {
      _isFavorite = widget.item.isFavorite;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_sending) return;

    final id = widget.item.id;
    if (id <= 0) return;

    final previous = _isFavorite;
    setState(() => _isFavorite = !_isFavorite);

    _sending = true;

    try {
      debugPrint("❤️ toggle fav id=$id  prev=$previous -> now=$_isFavorite");

      final favCubit = context.read<FavoritesCubit>();
      final res = await favCubit.toggle(id);

      debugPrint("✅ toggle result ok=${res.ok} msg=${res.message}");

      if (!res.ok) {
        setState(() => _isFavorite = previous);
        EasyLoading.showError(res.message ?? "Failed");
      }
    } catch (e, st) {
      debugPrint("❌ toggle fav crashed: $e\n$st");
      setState(() => _isFavorite = previous);
      EasyLoading.showError("Failed: $e");
    } finally {
      _sending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = UrlHelper.toFullUrl(widget.item.primaryImage?.imageUrl);

    final title = context.pick(ar: widget.item.nameAr, en: widget.item.nameEn);

    // ✅ منطق الخصم الموحد
    final hasDiscount =
        widget.item.hasDiscount == true && (widget.item.discountValue ?? 0) > 0;

    final before = (widget.item.priceBefore > 0)
        ? widget.item.priceBefore
        : (widget.item.priceAfter > 0 ? widget.item.priceAfter : 0);

    final after = (widget.item.priceAfter > 0)
        ? widget.item.priceAfter
        : (widget.item.priceBefore > 0 ? widget.item.priceBefore : 0);

    final discountType = (widget.item.discountType ?? "percentage")
        .toLowerCase();
    final discountValue = (widget.item.discountValue ?? 0).toDouble();

    String _discountBadgeText(BuildContext context) {
      if (!hasDiscount) return "";

      // percentage
      if (discountType == "percentage") {
        // إذا السيرفر بعت percent ضمن discountValue
        if (discountValue > 0) return "-${discountValue.toStringAsFixed(0)}%";

        // fallback: احسبها من قبل/بعد
        final p = ((before - after) / before) * 100;
        return "-${p.toStringAsFixed(0)}%";
      }

      // fixed amount
      if (discountType == "fixed") {
        // discountValue مبلغ الخصم
        if (discountValue > 0) return "-${context.syp(discountValue)}";
        // fallback: احسب مبلغ الخصم من قبل/بعد
        return "-${context.syp(before - after)}";
      }

      // أي نوع غير معروف: اعرض فرق السعر
      return "-${context.syp(before - after)}";
    }

    final percent = (widget.item.discountValue ?? 0).toDouble();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        // color: AppColor.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE =================
          Stack(
            children: [
              // SizedBox(
              //   width: 145.h,
              //   height: 145.h,
              //   child: ClipRRect(
              //     borderRadius: BorderRadiusDirectional.only(
              //       topStart: Radius.circular(12.r),
              //       topEnd: Radius.circular(12.r),
              //       bottomStart: Radius.circular(12.r),
              //       bottomEnd: Radius.circular(12.r),
              //     ),
              //
              //     child: (imageUrl == null || imageUrl.isEmpty)
              //         ? _imageFallback()
              //         :
              //     Image.network(
              //       imageUrl,
              //       fit: BoxFit.cover,
              //       errorBuilder: (_, __, ___) => _imageFallback(),
              //     ),
              //   ),
              // ),

              // Positioned.fill(
              //   child: Container(color: Colors.black.withOpacity(0.25)),
              // ),
              SizedBox(
                width: 135.h,
                height: 145.h,
                child: AppNetworkImage(
                  path: imageUrl,
                  height: 135.h,
                  width: 145.h,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(16.r),
                  fallback: _imageFallback(),
                ),
              ),

              if (hasDiscount)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadiusDirectional.only(
                        topEnd: Radius.circular(12.r),
                        bottomEnd: Radius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      _discountBadgeText(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // Favorite
              PositionedDirectional(
                top: 4,
                end: 4,
                child: LikeButton(
                  size: 26,
                  isLiked: _isFavorite,
                  animationDuration: const Duration(milliseconds: 500),
                  circleColor: CircleColor(
                    start: Colors.redAccent,
                    end: Colors.red,
                  ),
                  bubblesColor: const BubblesColor(
                    dotPrimaryColor: Colors.red,
                    dotSecondaryColor: Colors.redAccent,
                  ),
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                      size: 22,
                    );
                  },
                  onTap: (bool isLiked) async {
                    if (_sending) return isLiked;

                    await _toggleFavorite();

                    // مهم جداً نرجع الحالة الجديدة الفعلية
                    return _isFavorite;
                  },
                ),
              ),
            ],
          ),

          // ================= TEXT AREA =================
          Container(
            // height: 60.h,

            width: 142.w,
            // padding: EdgeInsets.symmetric(vertical: 5),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
                ),

                if (!hasDiscount)
                  Text(
                    context.syp(after),
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 12.sp,
                      // fontWeight: FontWeight.bold,
                      fontFamily:
                          Localizations.localeOf(context).languageCode == 'ar'
                          ? 'Cairo'
                          : 'Inter',
                    ),
                  )
                else
                  Row(
                    children: [
                      Text(
                        context.syp(before),
                        style: TextStyle(
                          color: AppColor.LightActive,
                          fontSize: 11.sp,
                          decoration: TextDecoration.lineThrough,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'Cairo'
                              : 'Inter',
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        context.syp(after),
                        style: TextStyle(
                          color: AppColor.red,
                          fontSize: 12.sp,
                          // fontWeight: FontWeight.w800,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'Cairo'
                              : 'Inter',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/meal_breeze.jpeg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}

class MostPopular extends StatelessWidget {
  const MostPopular({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

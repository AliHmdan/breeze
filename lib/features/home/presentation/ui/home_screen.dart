import 'dart:developer';
import 'dart:async';

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/have_order.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/app/bloc/app_cubit.dart' show AppCubit;
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/home_scroll_controller.dart';
import 'package:breezefood/features/home/presentation/ui/sections/Stores.dart';
import 'package:breezefood/features/home/presentation/ui/sections/all_resturant.dart';
import 'package:breezefood/features/home/presentation/ui/sections/breakfast_restaurants.dart';
import 'package:breezefood/features/home/presentation/ui/sections/Open_now.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_delivery/discount_delivery_home.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_meals/discount_home.dart';
import 'package:breezefood/features/home/presentation/ui/sections/sweets_restaurants.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/home_tabs_bar.dart';
import 'package:breezefood/features/orders/model/cart_response.dart'
    show CartResponse;
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart'
    show ProfileCubit;
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/assistant/presentation/ui/assistant_chat_sheet.dart';

import 'package:breezefood/features/home/presentation/ui/sections/supermarketslider.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/cart_summary_model.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'
    show OrderInfo;
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:breezefood/features/super_market/categories_screen.dart';
import 'package:breezefood/features/super_market/market_page_price.dart';
import 'package:breezefood/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// Import the grid pages
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_meals/discount_home.dart'
    show DiscountRestaurantsGridPage;
import 'package:breezefood/features/home/presentation/ui/sections/sweets_restaurants_grid_page.dart';
import 'package:breezefood/features/home/presentation/ui/sections/breakfast_restaurants_grid_page.dart';
import 'package:breezefood/features/home/presentation/ui/sections/supermarkets_grid_page.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discounts_delivery/discount_delivery_grid_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with RouteAware, SingleTickerProviderStateMixin {
  bool _subscribed = false;

  late final AnimationController _robotBobController;
  late final Animation<double> _robotBob;

  // ✅ Controller تبع السكرول + tabs sync
  late final HomeScrollController homeScroll = HomeScrollController(
    debugEnabled: kDebugMode,
  )..init();

  late final HomeCubit cubit;

  Future<void> _bootstrap() async {
    final home = getIt<HomeCubit>();
    final profile = getIt<ProfileCubit>();
    final cart = getIt<CartCubit>();

    // // لو فشل GPS ما بدنا نوقف كل شيء
    // try {
    //   await home.sendMyLocationOnce();
    // } catch (_) {}
    print("ali mostafa for coding");

    // load كلاتهم سوا
    await Future.wait([home.load(), profile.load(), cart.loadCart()]);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();

    _robotBobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _robotBob = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _robotBobController, curve: Curves.easeInOut),
    );

    cubit = context.read<HomeCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // 1) حمّل السلة بصمت أولاً (ليظهر View Cart مباشرة لو السلة فيها عناصر)
      try {
        await context.read<CartCubit>().loadCart(silent: true);
      } catch (_) {}

      // 2) حمّل بيانات الهوم أولاً (أولوية قصوى لسرعة العرض)
      final isLoadedOrLoading = cubit.state.maybeWhen(
        loading: () => true,
        loaded: (_) => true,
        orElse: () => false,
      );

      if (!isLoadedOrLoading) {
        await cubit.load();
        if (!mounted) return;
      }

      // 3) ابعت اللوكيشن في الخلفية بعد تحميل الهوم (لا يؤثر على عرض الهوم)
      unawaited(cubit.sendMyLocationOnce());

      // 4) بعد ما تخلص أول فريم + تحميل البيانات:
      // اعمل refresh للـ offsets (بدون postFrame ثاني)
      homeScroll.activeIndex.value = homeScroll.activeIndex.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscribed) return;

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    if (_subscribed) routeObserver.unsubscribe(this);
    homeScroll.dispose();
    _robotBobController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    log("🏠 didPopNext -> refresh cart");
    context.read<CartCubit>().loadCart(silent: true);
    cubit.load(silent: true);
  }

  // ===== Helpers =====
  int _extractId(dynamic x) {
    if (x == null) return 0;

    if (x is Map) {
      final v = x["id"] ?? x["restaurant_id"] ?? x["market_id"];
      return int.tryParse(v.toString()) ?? 0;
    }

    try {
      final v = (x as dynamic).id;
      return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    try {
      final v = (x as dynamic).restaurantId;
      return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    return 0;
  }

  String _extractImage(dynamic x) {
    if (x == null) return "";
    if (x is Map)
      return (x["cover_image"] ?? x["cover_image"] ?? "").toString();

    try {
      return ((x as dynamic).name ?? "").toString();
    } catch (_) {}

    return "";
  }

  String _extractTitle(dynamic x) {
    if (x == null) return "";
    if (x is Map) return (x["name"] ?? x["title"] ?? "").toString();

    try {
      return ((x as dynamic).name ?? "").toString();
    } catch (_) {}

    return "";
  }

  Future<void> _refreshHomeAndCart() async {
    if (!mounted) return;
    await Future.wait([
      cubit.load(),
      Future(() {
        try {
          return context.read<CartCubit>().loadCart(silent: true);
        } catch (_) {
          return Future.value();
        }
      }),
    ]);

    // ✅ بعد الريفرش بيصير أحجام تتغير
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });

    // ✅ أرسل اللوكيشن في الخلفية بعد الريفرش (لا يؤثر على الأداء)
    unawaited(cubit.sendMyLocationOnce());
  }

  Future<void> _openRestaurant(dynamic r) async {
    final id = _extractId(r);
    final image = _extractImage(r);
    print('heloo ${r}');
    print('heloo ${image}');
    // String image=r.
    if (id == 0) return;

    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider(create: (_) => getIt<RatingSubmitCubit>()),
            BlocProvider(create: (_) => getIt<FavoritesCubit>()),
          ],
          child: ResturantDetails(restaurant_id: id),
        ),
      ),
    );

    if (!mounted) return;

    // إذا صار تغيير (اضافة للسلة) اعمل loadCart بدون silent مرة واحدة
    if (changed == true) {
      await context.read<CartCubit>().loadCart(silent: false);
    } else {
      // إذا ما في تغيير، خليها silent خفيف
      context.read<CartCubit>().loadCart(silent: true);
    }
  }

  Future<void> _openMarket(dynamic m) async {
    final id = _extractId(m);
    if (id == 0) return;

    final title = _extractTitle(m).trim();
    final homeData = cubit.state.maybeWhen(
      loaded: (d) => d,
      orElse: () => null,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarketCategoriesScreen(
          marketId: id,
          title: title.isEmpty ? "Market" : title,
          // haveOrder: homeData?.haveOrder,
        ),
      ),
    );

    context.read<CartCubit>().loadCart(silent: true);
  }

  Widget _shimmerBox({
    required double height,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10),
  }) {
    return Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: AppColor.search,
        highlightColor: AppColor.primaryColor.withOpacity(0.3),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColor.search,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColor.primaryColor.withOpacity(0.35)),
          ),
        ),
      ),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      builder: (context, state) {
        final loading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final homeData = state.maybeWhen(
          loaded: (data) => data,
          orElse: () => null,
        );
        final haveOrder = homeData?.haveOrder;

        final cartHasItems = context.watch<CartCubit>().state.maybeWhen(
          cartLoaded: (cart, updatingIds, toast, isRefreshing) {
            // عدّلها حسب موديلك:
            final itemsCount = cart.items.length;
            return itemsCount > 0;
          },
          orElse: () => false,
        );

        final showBottom = (haveOrder != null) || cartHasItems;

        final sections = <_HomeSectionDef>[
          // 1️⃣ Story
          _HomeSectionDef(
            id: "story",
            title: "home.filters.stores".tr(),
            builder: () => loading
                ? _shimmerBox(height: 178.h)
                : state.maybeWhen(
                    loaded: (data) =>
                        StoriesSlider(stories: data.stories, onTap: (story) {}),
                    orElse: () => const SizedBox.shrink(),
                  ),
          ),

          // 2️⃣ Open Now
          _HomeSectionDef(
            id: "open_now",
            title: "home.open_now".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                if (homeData?.nearbyRestaurants.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (_) => AllResturant(restaurants: homeData?.nearbyRestaurants ?? [], onTap: _openRestaurant),
                            builder: (_) => SweetsRestaurantsGridPage(
                              restaurants: homeData!.nearbyRestaurants,
                              screenTitle: "home.open_now".tr(),
                            ),
                          ),
                        );
                      },
                      child: CustomTitleSection(
                        title: "home.open_now".tr(),
                        all: "common.all".tr(),
                        icon: Icons.arrow_forward_ios_outlined,
                        ontap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (_) => AllResturant(restaurants: homeData?.nearbyRestaurants ?? [], onTap: _openRestaurant),
                              builder: (_) => SweetsRestaurantsGridPage(
                                restaurants: homeData!.nearbyRestaurants,
                                screenTitle: "home.open_now".tr(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 0.h),
                loading
                    ? _shimmerBox(height: 178.h)
                    : state.maybeWhen(
                        loaded: (data) => OpenNow(
                          restaurants: data.nearbyRestaurants,
                          onTap: _openRestaurant,
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
              ],
            ),
          ),

          // 3️⃣ Discounts
          _HomeSectionDef(
            id: "discounts",
            title: "home.filters.discounts".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                if (homeData?.discounts.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DiscountRestaurantsGridPage(
                              discounts: homeData?.discounts ?? [],
                            ),
                          ),
                        );
                      },
                      child: CustomTitleSection(
                        title: "home.filters.discounts".tr(),
                        all: "common.all".tr(),
                        icon: Icons.arrow_forward_ios_outlined,
                        ontap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DiscountRestaurantsGridPage(
                                discounts: homeData?.discounts ?? [],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 0.h),
                loading
                    ? _shimmerBox(height: 130.h)
                    : state.maybeWhen(
                        loaded: (data) =>
                            DiscountHome(discounts: data.discounts),
                        orElse: () => const SizedBox.shrink(),
                      ),
              ],
            ),
          ),

          // 4️⃣ Delivery Discounts
          _HomeSectionDef(
            id: "delivery_discounts",
            title: "home.filters.delivery".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                if (homeData?.discountDelivery.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DiscountDeliveryGridPage(
                              discountDelivery:
                                  homeData?.discountDelivery ?? [],
                            ),
                          ),
                        );
                      },
                      child: CustomTitleSection(
                        title: "home.filters.delivery".tr(),
                        all: "common.all".tr(),
                        icon: Icons.arrow_forward_ios_outlined,
                        ontap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DiscountDeliveryGridPage(
                                discountDelivery:
                                    homeData?.discountDelivery ?? [],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 0.h),
                loading
                    ? _shimmerBox(height: 130.h)
                    : state.maybeWhen(
                        loaded: (data) => Padding(
                          padding: EdgeInsetsDirectional.only(start: 0.w),
                          child: DiscountDeliveryHome(
                            discountDelivery: data.discountDelivery,
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
              ],
            ),
          ),
        ];

        final sweetsList = homeData?.sweets ?? const [];

        if (sweetsList.isNotEmpty) {
          sections.add(
            _HomeSectionDef(
              id: "sweets",
              title: "home.sweets".tr(),
              builder: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  if (homeData?.sweets.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SweetsRestaurantsGridPage(
                                restaurants: sweetsList,
                              ),
                            ),
                          );
                        },
                        child: CustomTitleSection(
                          title: "home.sweets".tr(),
                          all: "common.all".tr(),
                          icon: Icons.arrow_forward_ios_outlined,
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SweetsRestaurantsGridPage(
                                  restaurants: sweetsList,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 10.h),
                  loading
                      ? _shimmerBox(height: 178.h)
                      : Padding(
                          padding: EdgeInsetsDirectional.only(start: 0.w),
                          child: SweetsRestaurantsSection(
                            restaurants: sweetsList,
                            onTap: _openRestaurant,
                          ),
                        ),
                ],
              ),
            ),
          );
        }
        final breakfastList = homeData?.breakfastRestaurants ?? const [];

        if (breakfastList.isNotEmpty) {
          sections.add(
            _HomeSectionDef(
              id: "breakfast",
              title: "home.breakfast_restaurants".tr(),
              builder: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  if (homeData?.breakfastRestaurants.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BreakfastRestaurantsGridPage(
                                restaurants: breakfastList,
                              ),
                            ),
                          );
                        },
                        child: CustomTitleSection(
                          title: "home.breakfast_restaurants".tr(),
                          all: "common.all".tr(),
                          icon: Icons.arrow_forward_ios_outlined,
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BreakfastRestaurantsGridPage(
                                  restaurants: breakfastList,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 0.w),
                    child: BreakfastRestaurantsSection(
                      restaurants: breakfastList,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        sections.add(
          _HomeSectionDef(
            id: "supermarket",
            title: "home.super_market".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (homeData?.supermarkets.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SupermarketsGridPage(
                              supermarkets: homeData?.supermarkets ?? [],
                            ),
                          ),
                        );
                      },
                      child: CustomTitleSection(
                        title: "home.super_market".tr(),
                        all: "common.all".tr(),
                        icon: Icons.arrow_forward_ios_outlined,
                        ontap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupermarketsGridPage(
                                supermarkets: homeData?.supermarkets ?? [],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 10.h),
                state.maybeWhen(
                  loaded: (data) => Supermarketslider(
                    restaurants: data.supermarkets,
                    onTap: _openMarket,
                    onRateSuccess: () => cubit.load(),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
        sections.add(
          _HomeSectionDef(
            id: "all_restaurants",
            title: "home.all_resturant".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (homeData?.allRestaurants.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllResturant(
                              restaurants: homeData?.allRestaurants ?? [],
                              onTap: _openRestaurant,
                            ),
                          ),
                        );
                      },
                      child: CustomTitleSection(
                        title: "home.all_resturant".tr(),
                        all: "common.all".tr(),
                        icon: Icons.arrow_forward_ios_outlined,
                        ontap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllResturant(
                                restaurants: homeData?.allRestaurants ?? [],
                                onTap: _openRestaurant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 10.h),
                loading
                    ? _shimmerBox(height: 320.h)
                    : state.maybeWhen(
                        loaded: (data) => AllResturant(
                          restaurants: data.allRestaurants,
                          onTap: _openRestaurant,
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
              ],
            ),
          ),
        );
        homeScroll.setKeysCount(sections.length);

        final tabTitles = sections.map((s) => s.title).toList();

        final safeActive = homeScroll.activeIndex.value.clamp(
          0,
          (tabTitles.isEmpty ? 0 : tabTitles.length - 1),
        );

        if (safeActive != homeScroll.activeIndex.value) {
          homeScroll.activeIndex.value = safeActive;
        }
        if (tabTitles.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final fabBottomPadding =
            (showBottom ? 90.h : 24.h) + MediaQuery.of(context).padding.bottom;
        final isDark = AppCubit.get(context).isThemDark();

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: isDark ? Color(0xff363535) : Color(0xffd9d6d6),

            statusBarIconBrightness: Brightness.light, // icons color
          ),
          child: Scaffold(
            // backgroundColor: Theme.of(context).colorScheme.surface,
            backgroundColor: AppColor.Dark,
            floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom: fabBottomPadding),
              child: FloatingActionButton(
                heroTag: 'assistant_robot_fab',
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                onPressed: () => showAssistantChatSheet(context),
                child: SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 30.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            // color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.25),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _robotBob,

                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _robotBob.value),
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/icons/pnj ROBOT.png',
                          width: 56.w,
                          height: 56.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshHomeAndCart,
                  color: AppColor.primaryColor,
                  backgroundColor: AppColor.Dark,
                  elevation: 0,

                  child: CustomScrollView(
                    controller: homeScroll.controller,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            AppbarHome(home: homeData, homeCubit: cubit),
                            // SizedBox(height: 14.h),
                          ],
                        ),
                      ),

                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyTabsHeader(
                          height: 50.h,
                          child: SizedBox.expand(
                            child: Container(
                              key: homeScroll.tabsKey,
                              color: AppColor.search,
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 0,
                              ),
                              child: ValueListenableBuilder<int>(
                                valueListenable: homeScroll.activeIndex,
                                builder: (_, active, __) {
                                  return HomeTabsBar(
                                    titles: tabTitles,
                                    activeIndex: active,
                                    onTap: (i) => homeScroll.scrollToSection(i),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== Sections =====
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(height: 14.h),
                            ...List.generate(sections.length, (i) {
                              return Column(
                                children: [
                                  SizedBox(
                                    key: homeScroll.sectionKeys[i],
                                    height: 0,
                                  ), // ✅ فقط هون
                                  sections[i].builder(),
                                  SizedBox(height: 14.h),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: showBottom ? 90.h : 24.h),
                      ),
                    ],
                  ),
                ),
                // ===== Bottom action (Cart / Order) =====
                if (showBottom)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: BlocBuilder<HomeCubit, HomeState>(
                        bloc: cubit,
                        builder: (context, st) {
                          final haveOrder = st.maybeWhen(
                            loaded: (d) => d.haveOrder,
                            orElse: () => null,
                          );

                          // ✅ مرر haveOrder (قد يكون null) وخلي الويدجت تقرر شو تعرض
                          return _HomeBottomAction(
                            homeCubit: cubit,
                            haveOrder: haveOrder,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeBottomAction extends StatelessWidget {
  final HomeCubit homeCubit;
  final OrderInfo? haveOrder;

  const _HomeBottomAction({required this.homeCubit, required this.haveOrder});

  double totalPriceForItems(CartResponse? cart) {
    double sum = 0.0;
    for (int i = 0; i < cart!.items.length; i++) {
      sum = sum + cart!.items[i].totalPrice;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, st) {
        final cart = st.maybeWhen(
          cartLoaded: (cart, updatingIds, toast, isRefreshing) => cart,
          orElse: () => null,
        );

        // 1) ✅ إذا في سلة وفيها عناصر -> View Cart
        if (cart != null) {
          final summary = CartSummary.from(cart);
          final totalPrice = totalPriceForItems(cart);

          // Additional check: hide button if no items or total is 0
          if (summary.hasCart && cart.items.isNotEmpty && totalPrice > 0) {
            final title =
                "${'cart.view_cart'.tr()}      "
                // "• ${summary.count} • "
                // "${context.syp(summary.total, decimals: 0)}";
                "${context.syp(totalPrice, decimals: 0)}";

            return CustomButton(
              title: title,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: context.read<CartCubit>()),
                        BlocProvider(create: (_) => getIt<OrderFlowCubit>()),
                      ],
                      child: RequestOrderScreen(
                        // addressTitle: context.read<HomeCubit>().homeData!.provinceDetected ?? ''
                      ),
                    ),
                  ),
                );

                if (context.mounted) {
                  context.read<CartCubit>().loadCart(silent: true);
                  homeCubit.load(silent: true);
                }
              },
            );
          }
        }

        // 2) ✅ ما في سلة -> إذا في haveOrder اعرض Your Order
        if (haveOrder != null) {
          return CustomButtonOrder(
            title: "home.your_order".tr(),
            onPressed: () {
              openHaveOrderTracking(context, haveOrder!.id);
              if (context.mounted) {
                context.read<CartCubit>().loadCart(silent: true);
                homeCubit.load(silent: true);
              }
            },
          );
        }

        // 3) ✅ لا سلة ولا order -> لا تعرض شي
        return const SizedBox.shrink();
      },
    );
  }
}

class _StickyTabsHeader extends SliverPersistentHeaderDelegate {
  _StickyTabsHeader({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabsHeader oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _HomeSectionDef {
  final String id; // للـ filters mapping
  final String title; // للـ tabs
  final Widget Function() builder;

  _HomeSectionDef({
    required this.id,
    required this.title,
    required this.builder,
  });
}

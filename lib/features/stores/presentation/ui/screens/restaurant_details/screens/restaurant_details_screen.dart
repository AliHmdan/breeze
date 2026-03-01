import 'package:breezefood/android_swipe_back.dart';
import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/bottom_cart_action.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/ratings/presentation/ui/rate_dialog.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/restaurant_details_controller.dart';
import '../controller/restaurant_details_mapper.dart';
import 'widgets/rd_header_sliver.dart';
import 'widgets/rd_sticky_info_tabs_sliver.dart';
import 'widgets/rd_sections_sliver_list.dart';

class ResturantDetails extends StatefulWidget {
  final int restaurant_id;
  final int? initialMenuItemId;

  const ResturantDetails({
    super.key,
    required this.restaurant_id,
    this.initialMenuItemId,
  });

  @override
  State<ResturantDetails> createState() => _ResturantDetailsState();
}

class _ResturantDetailsState extends State<ResturantDetails>
    with SingleTickerProviderStateMixin {
  late final RestaurantDetailsScrollController scrollCtl =
      RestaurantDetailsScrollController()..init();

  late final RestaurantDetailsCubit cubit;

  final ScrollController _tabsController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  bool _isRestaurantOpen = true;

  bool _headerReady = false;
  String _headerUrl = "";
  final Set<String> _preloadedImages = {};

  double _headerZoom = 1.0;
  double _pullExtent = 0.0;

  double _headerOverlap = 24.0;

  late final AnimationController _overlapController;
  Animation<double>? _overlapAnim;

  VoidCallback? _activeIdxListener;

  void _scrollTabToActive(int index) {
    if (!_tabsController.hasClients) return;
    if (index < 0 || index >= _tabKeys.length) return;

    final ctx = _tabKeys[index].currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final tabGlobalX = box.localToGlobal(Offset.zero).dx;
    final tabWidth = box.size.width;

    final screenWidth = MediaQuery.of(ctx).size.width;
    final desiredCenterX = screenWidth * 0.5;
    final currentCenterX = tabGlobalX + tabWidth * 0.5;

    final delta = currentCenterX - desiredCenterX;

    final target = (_tabsController.offset + delta).clamp(
      _tabsController.position.minScrollExtent,
      _tabsController.position.maxScrollExtent,
    );

    _tabsController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _precacheImage(String url) async {
    if (url.isEmpty) return;
    if (_preloadedImages.contains(url)) return;

    try {
      await precacheImage(
        CachedNetworkImageProvider(url, cacheManager: AppCacheManager.instance),
        context,
      );
      _preloadedImages.add(url);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    cubit = getIt<RestaurantDetailsCubit>();

    _overlapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 230),
        )..addListener(() {
          final a = _overlapAnim;
          if (a == null) return;
          final v = a.value;
          if (_headerOverlap != v) setState(() => _headerOverlap = v);
        });

    _activeIdxListener = () {
      final idx = scrollCtl.activeIndex.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollTabToActive(idx);
      });
    };
    scrollCtl.activeIndex.addListener(_activeIdxListener!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load(widget.restaurant_id);

      try {
        context.read<CartCubit>().loadCart();
      } catch (_) {}

      scrollCtl.attachInner();
    });
  }

  @override
  void dispose() {
    final listener = _activeIdxListener;
    if (listener != null) {
      scrollCtl.activeIndex.removeListener(listener);
    }

    _overlapController.dispose();
    scrollCtl.dispose();
    _tabsController.dispose();
    super.dispose();
  }

  void _animateOverlapBack() {
    if (!mounted) return;
    if (_headerOverlap == 24.0) return;

    _overlapController.stop();
    _overlapController.reset();
    _overlapAnim = Tween<double>(begin: _headerOverlap, end: 24.0).animate(
      CurvedAnimation(parent: _overlapController, curve: Curves.easeOutCubic),
    );
    _overlapController.forward();
  }

  Widget _divider() {
    return Container(
      width: 0.5,
      height: 25.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColor.LightActive,
    );
  }

  Widget _loadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/wifi.png',
              width: 450.w,
              height: 450.h,
              fit: BoxFit.cover, // طريقة تمدد الصورة
            ),
            SizedBox(height: 10.h),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: () => cubit.load(widget.restaurant_id),
                child: Text("common.retry".tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, RestaurantDetailsResponse data) {
    final mostPopularItems = data.mostPopular;

    String headerImageUrl = "";
    String restaurantName = "";
    String reviewsCountText = "0";

    String deliveryTime = "--";
    String deliveryBase = "--";
    String deliveryFinal = "--";

    String avgRatingText = "0.0";

    int? myReviewId;
    double myUserRating = 0.0;

    List<String> categories = [];
    List<List<MenuItem>> itemsByCategory = [];
    List<MenuItem> discountedItems = [];

    final g = data.general;

    restaurantName = g.name;

    final newIsOpen = g.isOpen;
    if (_isRestaurantOpen != newIsOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _isRestaurantOpen = newIsOpen);
      });
    }

    headerImageUrl = RestaurantDetailsMapper.imageUrl(g.cover ?? g.logo);

    if (_headerUrl != headerImageUrl) {
      _headerUrl = headerImageUrl;
      _headerReady = false;

      _precacheImage(_headerUrl).then((_) {
        if (mounted) setState(() => _headerReady = true);
      });
    }

    reviewsCountText = "${g.reviewsCount}";

    final dt = (g.deliveryTime ?? "").trim();
    deliveryTime = dt.isEmpty ? "--" : dt;

    final del = g.delivery;
    if (del != null) {
      deliveryBase = context.money(del.baseFee, decimals: 0);
      deliveryFinal = context.money(del.finalFee, decimals: 0);
    } else {
      deliveryBase = context.money(g.deliveryCash, decimals: 0);
      deliveryFinal = context.money(g.deliveryCash, decimals: 0);
    }

    final avg = (g.avgRating > 0) ? g.avgRating : 0.0;
    avgRatingText = avg > 0 ? avg.toStringAsFixed(1) : "0.0";

    myReviewId = data.myRating?.id;
    myUserRating = data.myRating?.rating ?? 0.0;

    final sections = data.restaurantMenuItems;
    final hasMostPopular = mostPopularItems.isNotEmpty;

    final allItems = sections.expand((s) => s.items).toList();
    discountedItems = allItems.where((x) => x.hasDiscount).toList()
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    final hasDiscountSection = discountedItems.isNotEmpty;

    final totalCount =
        sections.length +
        (hasMostPopular ? 1 : 0) +
        (hasDiscountSection ? 1 : 0);

    scrollCtl.setCategoryKeys(totalCount);

    if (_tabKeys.length != totalCount) {
      _tabKeys
        ..clear()
        ..addAll(List.generate(totalCount, (_) => GlobalKey()));
    }

    final menuCats = sections.map((e) {
      return context.pick(ar: e.category.nameAr, en: e.category.nameEn);
    }).toList();

    categories = [
      if (hasDiscountSection) context.pick(ar: "الخصومات", en: "Discounts"),
      if (hasMostPopular) context.pick(ar: "الأكثر طلباً", en: "Most Popular"),
      ...menuCats,
    ];

    itemsByCategory = [
      if (hasDiscountSection) discountedItems,
      if (hasMostPopular) mostPopularItems,
      ...sections.map((e) => e.items),
    ];

    for (final section in sections) {
      for (final item in section.items.take(4)) {
        final img = RestaurantDetailsMapper.imageUrl(item.image);
        _precacheImage(img);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scrollCtl.attachInner();
      scrollCtl.recalcOffsets();
    });

    final showTwoPrices = deliveryBase != deliveryFinal;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              AnimatedScale(
                scale: _headerZoom,
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  height: 260.h,
                  child: ClipRect(
                    child: _headerReady
                        ? AppNetworkImage(
                            height: 260,
                            path: headerImageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/images/meal_breeze.jpeg",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              // Expanded(child: Container(color: AppColor.Dark)),
            ],
          ),
        ),

        ///
        /// here shadow
        ///
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.2),
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.8),
                Colors.green.withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.axis != Axis.vertical) return false;

            if (n is OverscrollNotification) {
              // In NestedScrollView, metrics.pixels often stays at 0. Use overscroll.
              // When pulling down beyond top, overscroll is typically negative.
              if (n.overscroll < 0) {
                if (_overlapController.isAnimating) {
                  _overlapController.stop();
                }
                final nextPull = (_pullExtent + (-n.overscroll)).clamp(
                  0.0,
                  120.0,
                );
                final nextZoom = (1.0 + (nextPull / 260.0)).clamp(1.0, 1.35);
                final nextOverlap = (24.0 + (nextPull * 0.35)).clamp(
                  24.0,
                  70.0,
                );
                if (nextPull != _pullExtent || nextZoom != _headerZoom) {
                  setState(() {
                    _pullExtent = nextPull;
                    _headerZoom = nextZoom.toDouble();
                    _headerOverlap = nextOverlap.toDouble();
                  });
                }
              }
            }

            if (n is ScrollUpdateNotification) {
              // If user scrolls down into content, ensure we reset.
              if (n.metrics.pixels > 0 &&
                  (_pullExtent != 0.0 || _headerZoom != 1.0)) {
                _overlapController.stop();
                setState(() {
                  _pullExtent = 0.0;
                  _headerZoom = 1.0;
                  _headerOverlap = 24.0;
                });
              }
            }

            if (n is ScrollEndNotification) {
              if (_pullExtent != 0.0 || _headerZoom != 1.0) {
                setState(() {
                  _pullExtent = 0.0;
                  _headerZoom = 1.0;
                });

                // Smoothly reset overlap back to 24
                _animateOverlapBack();
              }
            }

            return false;
          },
          child: NestedScrollView(
            key: scrollCtl.nestedKey,
            controller: scrollCtl.outer,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              scrollCtl.setStickyExtent(
                165.h,
              ); // نفس minExtent/maxExtent تبع RDStickyInfoTabsSliver

              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: RDHeaderSliver(
                    overlap: _headerOverlap,
                    innerBoxIsScrolled: innerBoxIsScrolled,
                    restaurantName: restaurantName,
                    avgRatingText: avgRatingText,
                    reviewsCountText: reviewsCountText,
                    onBack: () => Navigator.pop(context),
                    onSearch: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              Search(restaurantId: widget.restaurant_id),
                        ),
                      );
                    },
                  ),
                ),

                ValueListenableBuilder<int>(
                  valueListenable: scrollCtl.activeIndex,
                  builder: (_, activeIdx, __) {
                    return RDStickyInfoTabsSliver(
                      roundedTop: !innerBoxIsScrolled,
                      divider: _divider(),
                      deliveryTimeText: deliveryTime,
                      restaurantName: restaurantName,
                      deliveryBaseText: deliveryBase,
                      deliveryFinalText: deliveryFinal,
                      showTwoPrices: showTwoPrices,
                      categories: categories,
                      activeIndex: activeIdx,
                      onSearch: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                Search(restaurantId: widget.restaurant_id),
                          ),
                        );
                      },
                      onTapCategory: (i) {
                        if (scrollCtl.activeIndex.value != i) {
                          scrollCtl.activeIndex.value = i;
                        }
                        scrollCtl.scrollToCategory(i);
                      },
                      avgRatingText: avgRatingText,
                      reviewsCountText: reviewsCountText,
                      onRateTap: () async {
                        final reviewId = myReviewId;
                        final hasMyRating =
                            (reviewId ?? 0) > 0 && myUserRating > 0;

                        final res = await showRateDialog(
                          context,
                          currentRating: hasMyRating ? myUserRating : 3.0,
                          reviewId: hasMyRating ? reviewId : null,
                        );
                        if (res == null) return;

                        final submitCubit = context.read<RatingSubmitCubit>();
                        EasyLoading.show(status: "common.sending".tr());

                        if (res.delete) {
                          if ((reviewId ?? 0) == 0) {
                            EasyLoading.showError(
                              "reviews.no_review_to_delete".tr(),
                            );
                            return;
                          }

                          await submitCubit.deleteRestaurantRate(
                            reviewId: reviewId!,
                          );
                          if (!mounted) return;

                          submitCubit.state.maybeWhen(
                            deleteSuccess: () async {
                              EasyLoading.showSuccess(
                                "reviews.delete_success".tr(),
                              );
                              await cubit.load(widget.restaurant_id);
                            },
                            error: (msg) => EasyLoading.showError(msg.tr()),
                            orElse: () => EasyLoading.dismiss(),
                          );
                          return;
                        }

                        if (res.rating == null) {
                          EasyLoading.dismiss();
                          return;
                        }

                        await submitCubit.submitRestaurantRate(
                          restaurantId: widget.restaurant_id,
                          rating: res.rating!,
                        );

                        if (!mounted) return;

                        submitCubit.state.maybeWhen(
                          success: () async {
                            EasyLoading.showSuccess(
                              "reviews.rate_success".tr(),
                            );
                            await cubit.load(widget.restaurant_id);
                          },
                          error: (msg) => EasyLoading.showError(msg.tr()),
                          orElse: () => EasyLoading.dismiss(),
                        );
                      },
                    );
                  },
                ),
              ];
            },
            body: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => scrollCtl.attachInner(),
                );

                return Container(
                  color:
                      AppColor.Dark, // ✅ أهم سطر: يمنع ظهور الغلاف ورا الوجبات
                  child: RDSectionsSliverList(
                    restaurantId: widget.restaurant_id,
                    isRestaurantOpen: _isRestaurantOpen,
                    categories: categories,
                    itemsByCategory: itemsByCategory,
                    categoryKeys: scrollCtl.categoryKeys,
                    imageUrl: RestaurantDetailsMapper.imageUrl,
                    onContentSizeMayChange: () {
                      scrollCtl.attachInner();
                      scrollCtl.recalcOffsets();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => getIt<RatingSubmitCubit>())],
      child: SafeArea(
        child: AndroidSwipeBack(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            bottomNavigationBar: SafeArea(
              child: BottomCartAction(
                haveOrder: null,
                usePrimaryButton: true,
                showCountAndTotal: true,
                onViewCart: () async {
                  if (!_isRestaurantOpen) {
                    EasyLoading.showInfo(
                      "restaurant.closed_cannot_checkout".tr(),
                    );
                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: context.read<CartCubit>()),
                          BlocProvider(create: (_) => getIt<OrderFlowCubit>()),
                        ],
                        child: const RequestOrderScreen(),
                      ),
                    ),
                  );

                  if (context.mounted) {
                    try {
                      context.read<CartCubit>().loadCart();
                    } catch (_) {}
                  }
                },
              ),
            ),
            body: BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
              bloc: cubit,
              builder: (context, state) {
                return state.when(
                  initial: _loadingView,
                  loading: _loadingView,
                  error: _errorView,
                  loaded: (data) => _buildLoaded(context, data),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

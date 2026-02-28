import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'rd_tabs_bar.dart';

class RDStickyInfoTabsSliver extends StatelessWidget {
  const RDStickyInfoTabsSliver({
    super.key,
    required this.deliveryTimeText,
    required this.restaurantName,
    required this.deliveryBaseText,
    required this.deliveryFinalText,
    required this.showTwoPrices,
    required this.categories,
    required this.activeIndex,
    required this.onTapCategory,
    required this.divider,
    required this.roundedTop,

    // ✅ rating tap (بدك تحافظ عليها)
    required this.avgRatingText,
    required this.reviewsCountText,
    required this.onRateTap,
    required this.onSearch,
  });

  final String deliveryTimeText;
  final String restaurantName;
  final String deliveryBaseText;
  final String deliveryFinalText;
  final bool showTwoPrices;
  final bool roundedTop;

  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTapCategory;
  final Widget divider;

  final String avgRatingText;
  final String reviewsCountText;
  final VoidCallback onRateTap;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _RDStickyDelegate(
        roundedTop: roundedTop,
        child: Transform.translate(
          offset: Offset(0, roundedTop ? 0 : 0),
          child: Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.zero,
            child: Container(
              color: roundedTop ? AppColor.Dark : AppColor.Dark,
              height: roundedTop ? null : 128.8.h,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// this section will gown
                  ///
                  roundedTop
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.Dark,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: onRateTap,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(height: 12.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              avgRatingText,
                                              style: TextStyle(
                                                color: AppColor.white,
                                                fontSize: 11.5.sp,
                                                // fontWeight: FontWeight.w900,
                                                fontFamily: context.isAr
                                                    ? 'Cairo'
                                                    : 'Inter',
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              "($reviewsCountText)",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.65,
                                                ),
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: context.isAr
                                                    ? 'Cairo'
                                                    : 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          "restaurant.rate_us".tr(),
                                          style: TextStyle(
                                            color: AppColor.gryLighter,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: context.isAr
                                                ? 'Cairo'
                                                : 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                divider,
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 9.h),
                                      Image.asset(
                                        "assets/icons/new_del.png",
                                        width: 20.w,
                                        height: 20.h,
                                        color: AppColor.white,
                                      ),
                                      // Image.asset("assets/icons/brezee_motor.png", width: 50.w, height: 50.h, color: Colors.white),
                                      SizedBox(height: 12.h),
                                      if (showTwoPrices) ...[
                                        Text(
                                          deliveryBaseText,
                                          style: TextStyle(
                                            color: AppColor.LightActive,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: context.isAr
                                                ? 'Cairo'
                                                : 'Inter',
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          deliveryFinalText,
                                          style: TextStyle(
                                            color: AppColor.red,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: context.isAr
                                                ? 'Cairo'
                                                : 'Inter',
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          deliveryFinalText,
                                          style: TextStyle(
                                            color: AppColor.gryLighter,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: context.isAr
                                                ? 'Cairo'
                                                : 'Inter',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                divider,

                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 10.h),
                                      Image.asset(
                                        "assets/icons/clock_new.png",
                                        width: 17.w,
                                        height: 17.h,
                                        color: AppColor.white,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        deliveryTimeText,
                                        style: TextStyle(
                                          color: AppColor.gryLighter,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: context.isAr
                                              ? 'Cairo'
                                              : 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: 15.w,
                            top: 15.h,
                            bottom: 10.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  _TitleBlock(
                                    restaurantName: restaurantName,
                                    avgRatingText: avgRatingText,
                                    reviewsCountText: reviewsCountText,
                                    textColor: AppColor.white,
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: onSearch,

                                    icon: Icon(Icons.search, color: Colors.red),
                                  ),
                                  SizedBox(width: 12.w),
                                ],
                              ),
                            ],
                          ),
                        ),

                  // ===== Tabs =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: RDTabsBar(
                      categories: categories,
                      activeIndex: activeIndex,
                      onTap: onTapCategory,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  _TitleBlock({
    required this.restaurantName,
    required this.avgRatingText,
    required this.reviewsCountText,
    this.textColor,
  });

  final String restaurantName;
  final String avgRatingText;
  final String reviewsCountText;
  Color? textColor;

  @override
  Widget build(BuildContext context) {
    final font = context.isAr ? 'Cairo' : 'Inter';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurantName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 26.sp,
            height: 1.05,
            fontWeight: FontWeight.w900,
            fontFamily: font,
            shadows: [
              Shadow(
                color: AppColor.Dark.withOpacity(0.65),
                offset: const Offset(0, 3),
                blurRadius: 14,
              ),
              Shadow(
                color: AppColor.Dark.withOpacity(0.35),
                offset: const Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RDStickyDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool roundedTop;

  _RDStickyDelegate({required this.child, required this.roundedTop});

  @override
  bool shouldRebuild(covariant _RDStickyDelegate old) {
    return old.roundedTop != roundedTop || old.child != child;
  }

  @override
  double get minExtent => 165.h;

  @override
  double get maxExtent => 165.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }
}

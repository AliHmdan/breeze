import 'dart:ui';

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart' show CustomArrow;
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
        deliveryTimeText: deliveryTimeText,
        restaurantName: restaurantName,
        deliveryBaseText: deliveryBaseText,
        deliveryFinalText: deliveryFinalText,
        showTwoPrices: showTwoPrices,
        categories: categories,
        activeIndex: activeIndex,
        onTapCategory: onTapCategory,
        divider: divider,
        avgRatingText: avgRatingText,
        reviewsCountText: reviewsCountText,
        onRateTap: onRateTap,
        onSearch: onSearch,
      ),
    );
  }
}

class _RDHeaderProgressCrossFade extends StatelessWidget {
  const _RDHeaderProgressCrossFade({required this.t, required this.expanded, required this.compact});

  final double t;
  final Widget expanded;
  final Widget compact;

  @override
  Widget build(BuildContext context) {
    final clamped = t.clamp(0.0, 1.0);
    final expandedOpacity = 1.0 - clamped;
    final compactOpacity = clamped;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        IgnorePointer(
          ignoring: expandedOpacity < 0.6,
          child: Opacity(
            opacity: expandedOpacity,
            child: Transform.translate(offset: Offset(0, -6 * clamped), child: expanded),
          ),
        ),
        IgnorePointer(
          ignoring: compactOpacity < 0.6,
          child: Opacity(
            opacity: compactOpacity,
            child: Transform.translate(offset: Offset(0, 6 * (1 - compactOpacity)), child: compact),
          ),
        ),
      ],
    );
  }
}

class _RDExpandedInfoRow extends StatelessWidget {
  const _RDExpandedInfoRow({
    required this.deliveryTimeText,
    required this.deliveryBaseText,
    required this.deliveryFinalText,
    required this.showTwoPrices,
    required this.divider,
    required this.avgRatingText,
    required this.reviewsCountText,
    required this.onRateTap,
  });

  final String deliveryTimeText;
  final String deliveryBaseText;
  final String deliveryFinalText;
  final bool showTwoPrices;
  final Widget divider;
  final String avgRatingText;
  final String reviewsCountText;
  final VoidCallback onRateTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(color: AppColor.Dark, borderRadius: BorderRadius.circular(14.r)),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4.w),
                        Text(
                          avgRatingText,
                          style: TextStyle(color: AppColor.white, fontSize: 11.5.sp, fontFamily: context.isAr ? 'Cairo' : 'Inter'),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "($reviewsCountText)",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: context.isAr ? 'Cairo' : 'Inter',
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
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
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
                  Image.asset("assets/icons/new_del.png", width: 20.w, height: 20.h, color: AppColor.white),
                  SizedBox(height: 12.h),
                  if (showTwoPrices) ...[
                    Text(
                      deliveryBaseText,
                      style: TextStyle(
                        color: AppColor.LightActive,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      deliveryFinalText,
                      style: TextStyle(
                        color: AppColor.red,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),
                  ] else
                    Text(
                      deliveryFinalText,
                      style: TextStyle(
                        color: AppColor.gryLighter,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
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
                  Image.asset("assets/icons/clock_new.png", width: 17.w, height: 17.h, color: AppColor.white),
                  SizedBox(height: 10.h),
                  Text(
                    deliveryTimeText,
                    style: TextStyle(
                      color: AppColor.gryLighter,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: context.isAr ? 'Cairo' : 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RDCompactHeaderRow extends StatelessWidget {
  const _RDCompactHeaderRow({required this.restaurantName, required this.avgRatingText, required this.reviewsCountText, required this.onSearch});

  final String restaurantName;
  final String avgRatingText;
  final String reviewsCountText;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 8.w, end: 8.w, top: 12.h, bottom: 6.h),
      child: Row(
        children: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          //   icon: const Icon(Icons.arrow_back_ios, color: Colors.red),
          // ),
          Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(width: 42.w, height: 42.w, color: Colors.transparent),
              ),
              _GlassCircleButton(
                onTap: () {
                  Navigator.of(context).pop();
                },
                height: 32.w,
                width: 32.w,
                child: CustomArrow(
                  color: AppColor.white,
                  background: Colors.transparent,
                  colorborder: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _TitleBlock(
              restaurantName: restaurantName,
              avgRatingText: avgRatingText,
              reviewsCountText: reviewsCountText,
              textColor: AppColor.white,
              maxLines: 1,
              fontSize: 16.sp,
              addShadows: false,
            ),
          ),
          Stack(
            children: [
              InkWell(
                onTap: onSearch,
                child: Container(width: 42.w, height: 42.w, color: Colors.transparent),
              ),
              _GlassCircleButton(
                onTap: onSearch,
                width: 32.w,
                height: 32.w,
                child: Icon(Icons.search, color: AppColor.white, size: 22),
              ),
            ],
          ),

          // IconButton(
          //   onPressed: onSearch,
          //   icon: const Icon(Icons.search, color: Colors.red),
          // ),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  _GlassCircleButton({required this.child, required this.onTap, this.width, this.height});

  final Widget child;
  final VoidCallback onTap;
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: width ?? 42.w,
              height: height ?? 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                shape: BoxShape.circle,
              ),
              child: child,
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
    this.maxLines = 2,
    this.fontSize,
    this.addShadows = true,
  });

  final String restaurantName;
  final String avgRatingText;
  final String reviewsCountText;
  final Color? textColor;
  final int maxLines;
  final double? fontSize;
  final bool addShadows;

  @override
  Widget build(BuildContext context) {
    final font = context.isAr ? 'Cairo' : 'Inter';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurantName,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: fontSize ?? 26.sp,
            height: 1.05,
            fontWeight: FontWeight.w900,
            fontFamily: font,
            shadows: addShadows
                ? [
                    Shadow(color: AppColor.Dark.withOpacity(0.65), offset: const Offset(0, 3), blurRadius: 14),
                    Shadow(color: AppColor.Dark.withOpacity(0.35), offset: const Offset(0, 1), blurRadius: 4),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

class _RDStickyDelegate extends SliverPersistentHeaderDelegate {
  final bool roundedTop;

  final String deliveryTimeText;
  final String restaurantName;
  final String deliveryBaseText;
  final String deliveryFinalText;
  final bool showTwoPrices;
  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTapCategory;
  final Widget divider;
  final String avgRatingText;
  final String reviewsCountText;
  final VoidCallback onRateTap;
  final VoidCallback onSearch;

  _RDStickyDelegate({
    required this.roundedTop,
    required this.deliveryTimeText,
    required this.restaurantName,
    required this.deliveryBaseText,
    required this.deliveryFinalText,
    required this.showTwoPrices,
    required this.categories,
    required this.activeIndex,
    required this.onTapCategory,
    required this.divider,
    required this.avgRatingText,
    required this.reviewsCountText,
    required this.onRateTap,
    required this.onSearch,
  });

  @override
  bool shouldRebuild(covariant _RDStickyDelegate old) {
    return old.roundedTop != roundedTop ||
        old.deliveryTimeText != deliveryTimeText ||
        old.restaurantName != restaurantName ||
        old.deliveryBaseText != deliveryBaseText ||
        old.deliveryFinalText != deliveryFinalText ||
        old.showTwoPrices != showTwoPrices ||
        old.categories != categories ||
        old.activeIndex != activeIndex ||
        old.onTapCategory != onTapCategory ||
        old.divider != divider ||
        old.avgRatingText != avgRatingText ||
        old.reviewsCountText != reviewsCountText ||
        old.onRateTap != onRateTap ||
        old.onSearch != onSearch;
  }

  @override
  double get minExtent => 128.8.h;

  @override
  double get maxExtent => 165.h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = (maxExtent - minExtent).clamp(1.0, 9999.0);
    final rawT = (shrinkOffset / range).clamp(0.0, 1.0);
    final t = Curves.easeOutCubic.transform(rawT);

    final tabsOpacity = 1.0 - (0.08 * t);
    final tabsOffsetY = 0.02 * t;

    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.zero,
      child: Container(
        color: AppColor.Dark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RDHeaderProgressCrossFade(
              t: t,
              expanded: _RDExpandedInfoRow(
                deliveryTimeText: deliveryTimeText,
                deliveryBaseText: deliveryBaseText,
                deliveryFinalText: deliveryFinalText,
                showTwoPrices: showTwoPrices,
                divider: divider,
                avgRatingText: avgRatingText,
                reviewsCountText: reviewsCountText,
                onRateTap: onRateTap,
              ),
              compact: _RDCompactHeaderRow(
                restaurantName: restaurantName,
                avgRatingText: avgRatingText,
                reviewsCountText: reviewsCountText,
                onSearch: onSearch,
              ),
            ),

            Opacity(
              opacity: tabsOpacity,
              child: Transform.translate(
                offset: Offset(0, 10 * tabsOffsetY),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: RDTabsBar(categories: categories, activeIndex: activeIndex, onTap: onTapCategory),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

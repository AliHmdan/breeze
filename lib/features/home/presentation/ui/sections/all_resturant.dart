import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/services/del_price_helper.dart' show deliveryFeeText;
import 'package:breezefood/core/services/detect_language.dart' show extractLocalizedText;
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:breezefood/features/home/model/home_response.dart' as home;

class RestaurantCard extends StatefulWidget {
  final home.HomeRestaurantModel restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({super.key, required this.restaurant, this.onTap});

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = (widget.restaurant.ratingAvg).toDouble();
  }

  @override
  void didUpdateWidget(covariant RestaurantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurant.id != widget.restaurant.id || oldWidget.restaurant.ratingAvg != widget.restaurant.ratingAvg) {
      _rating = (widget.restaurant.ratingAvg).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final r = widget.restaurant;

    final cover = UrlHelper.toFullUrl(r.coverImage);
    final logo = UrlHelper.toFullUrl(r.logo);
    final imageUrl = (cover ?? "").trim().isNotEmpty ? cover : logo;

    final ratingCount = r.ratingCount;
    final ordersText = ratingCount > 0 ? "$ratingCount Ratings" : "New";

    // ✅ سعر التوصيل (من helper اللي عملناه)
    final feeText = deliveryFeeText(r);

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  // ✅ Open/Closed badge
                  AppNetworkImage(
                    path: imageUrl,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    radius: BorderRadius.circular(12.r), // إذا بدك حواف
                    fallback: Image.asset(
                      "assets/images/meal_breeze.jpeg", // صورتك الافتراضية
                      height: 180.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (!r.isOpen)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(color: colorScheme.inverseSurface.withOpacity(0.45), borderRadius: BorderRadius.circular(12.r)),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),

                            child: CustomSubTitle(subtitle: "restaurant.closed".tr(), color: AppColor.red, fontsize: 13.sp),
                          ),
                        ),
                      ),
                    ),

                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(color: colorScheme.inverseSurface.withOpacity(0.30), borderRadius: BorderRadius.circular(20.r)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 3.w),
                          Text(
                            _rating.toStringAsFixed(1),
                            style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.h),
            CustomSubTitle(
              // subtitle: '(r.name).trim()',
              subtitle: extractLocalizedText(r.name, context.locale),
              color: AppColor.white,
              fontsize: 15.sp,
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),

              child: Row(
                children: [
                  Image.asset("assets/icons/new_del.png", width: 15.w, height: 15.h, color: AppColor.white.withOpacity(0.7)),
                  SizedBox(width: 8.w),
                  CustomSubTitle(subtitle: feeText, color: AppColor.white.withOpacity(0.7), fontsize: 11.sp),
                ],
              ),
            ),
            SizedBox(height: 15.h),
          ],
        ),
      ),
    );
  }
}

class AllResturant extends StatelessWidget {
  final List<home.HomeRestaurantModel> restaurants;
  final void Function(home.HomeRestaurantModel r)? onTap;

  const AllResturant({super.key, required this.restaurants, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColor.Dark;
    if (restaurants.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Center(
          child: Text(
            "No restaurants available",
            style: TextStyle(color: colorScheme.withOpacity(0.7), fontSize: 12.sp),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,

      physics: const BouncingScrollPhysics(),
      itemCount: restaurants.length,
      padding: EdgeInsetsDirectional.only(top: 60.h),
      separatorBuilder: (_, __) => Container(height: 12.h, color: AppColor.Dark),
      itemBuilder: (context, index) {
        final r = restaurants[index];
        return Container(
          color: AppColor.Dark,
          child: RestaurantCard(restaurant: r, onTap: onTap == null ? null : () => onTap!(r)),
        );
      },
    );
  }
}

import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/del_price_helper.dart' show deliveryFeeText;
import 'package:breezefood/core/services/detect_language.dart' show extractLocalizedText;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:breezefood/features/home/model/home_response.dart' as home;
import 'package:flutter_svg/flutter_svg.dart';

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

    // ✅ سعر التوصيل (من helper اللي عملناه)
    final feeText = deliveryFeeText(r);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity, // نفس عرض Discount
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r), // نفس الخصومات
                    child: AspectRatio(
                      aspectRatio: 16 / 9, //
                      child: AppNetworkImage(
                        path: imageUrl,
                        height: 100.h, // نفس ارتفاع الصورة
                        width: double.infinity,
                        fit: BoxFit.cover,
                        fallback: Image.asset("assets/images/meal_breeze.jpeg", fit: BoxFit.cover),
                      ),
                    ),
                  ),

                  // ⭐ Rating chip (نفس padding + نفس الحجم)
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

                  // 🔒 Closed overlay بنفس radius
                  if (!r.isOpen)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(color: colorScheme.inverseSurface.withOpacity(0.45), borderRadius: BorderRadius.circular(12.r)),
                        child: Center(
                          child: Text(
                            "restaurant.closed".tr(),
                            style: TextStyle(color: AppColor.red, fontSize: 13.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 0.h), // نفس gapH الطبيعي
              // 🏷️ Name (center مثل Discount)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: Text(
                  // r.name.trim(),
                  extractLocalizedText(r.name, context.locale),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColor.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
              ),

              SizedBox(height: 1.h),

              // 🚚 Delivery row بنفس padding الداخلي
              Padding(
                padding: EdgeInsetsDirectional.only(start: 0.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/icons/new_del.png", width: 15.w, height: 15.h, color: AppColor.white.withOpacity(0.6)),
                    SizedBox(width: 4.w),
                    Text(
                      context.syp(feeText, decimals: 0),
                      style: TextStyle(color: AppColor.white.withOpacity(0.6), fontSize: 11.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpenNow extends StatelessWidget {
  final List<home.HomeRestaurantModel> restaurants;
  final void Function(home.HomeRestaurantModel r)? onTap;

  const OpenNow({super.key, required this.restaurants, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (restaurants.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Center(
          child: Text(
            "No restaurants available",
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12.sp),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(top: 10, start: 0, end: 0.2),
      child: SizedBox(
        height: 160.h, // نفس منطق الخصومات

        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / 2.3;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsetsDirectional.only(start: 11.w),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final r = restaurants[index];

                return Container(
                  width: itemWidth,
                  // margin: EdgeInsetsDirectional.only(end: 10.w),
                  margin: EdgeInsetsDirectional.only(start: index == 0 ? 9.w : 0, end: 10.w),
                  child: RestaurantCard(restaurant: r, onTap: onTap == null ? null : () => onTap!(r)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

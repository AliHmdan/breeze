import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/open_status_badge.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Discount extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final dynamic price; // main price (meal price OR delivery final fee حسب استخدامك)
  final String discount;
  final bool? isOpen; // null => ما نعرض شي

  // ✅ Delivery prices (optional)
  final dynamic deliveryOldPrice; // base_fee
  final dynamic deliveryNewPrice; // final_fee
  final bool showDeliveryPrices;

  // ✅ Discount type badges (optional)
  final bool hasFoodDiscount;
  final bool hasDeliveryDiscount;

  final double rating;
  final int ratingCount;

  final void Function()? onTap;

  const Discount({
    super.key,
    required this.imagePath,
    required this.subtitle,
    required this.price,
    required this.discount,
    required this.rating,
    required this.isOpen,
    this.ratingCount = 0,
    this.onTap,
    this.deliveryOldPrice,
    this.deliveryNewPrice,
    this.showDeliveryPrices = false,
    this.hasFoodDiscount = false,
    this.hasDeliveryDiscount = false,
    // ✅ جديد
  });

  bool _hasDeliveryPrices() {
    final a = deliveryOldPrice;
    final b = deliveryNewPrice;
    final hasA = a != null && (a is num ? a > 0 : true);
    final hasB = b != null && (b is num ? b > 0 : true);
    return hasA || hasB;
  }

  String _badgeText() {
    final f = hasFoodDiscount;
    final d = hasDeliveryDiscount;
    if (f && d) return "BOTH";
    if (f) return "FOOD";
    if (d) return "DELIVERY";
    return "";
  }

  Color _badgeColor() {
    final f = hasFoodDiscount;
    final d = hasDeliveryDiscount;
    if (f && d) return Colors.purple;
    if (f) return Colors.green;
    if (d) return Colors.blue;
    return Colors.transparent;
  }

  Widget _buildImage(String url, {required double height}) {
    final u = url.trim();
    if (u.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(Icons.store, color: AppColor.white, size: 30.sp),
      );
    }

    return AppNetworkImage(
      path: u,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      fallback: Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Image.asset(
          "assets/images/meal_breeze.jpeg", // حط صورتك الافتراضية هون
          height: height,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratingText = (rating <= 0) ? "no_ratings_yet".tr() : rating.toStringAsFixed(1);
    final openText = (isOpen == true) ? "restaurant.open".tr() : "restaurant.closed".tr();

    final openColor = (isOpen == true) ? Colors.green : Colors.red;

    final showDelPrices = showDeliveryPrices && _hasDeliveryPrices();
    final badge = _badgeText();

    // ✅ أهم جزء: إذا في delivery prices قلّل ارتفاع الصورة + المسافات
    final imageH = showDelPrices ? 92.h : 100.h;
    final gapH = showDelPrices ? 4.h : 6.h;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,

        child: Container(
          width: 160.w,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: AppNetworkImage(
                      path: imagePath,
                      height: imageH,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      radius: BorderRadius.vertical(top: Radius.circular(16.r)),
                      fallback: Image.asset("assets/images/meal_breeze.jpeg", fit: BoxFit.cover),
                    ),
                  ),

                  // ✅ rating chip
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
                            ratingText,
                            style: TextStyle(color: colorScheme.onInverseSurface, fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen == false) const ClosedOverlay(),

                  // if (hasFoodDiscount && discount.trim().isNotEmpty)
                  //   PositionedDirectional(
                  //     bottom: 0,
                  //     start: 0,
                  //     child: Container(
                  //       padding: EdgeInsets.symmetric(
                  //         horizontal: 8.w,
                  //         vertical: 2.h,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: AppColor.red,
                  //         borderRadius: BorderRadiusDirectional.only(
                  //           // topStart:  Radius.circular(12.r),
                  //           bottomStart: Radius.circular(12.r),
                  //           topEnd: Radius.circular(20.r),
                  //           bottomEnd: Radius.circular(20.r),
                  //         ),
                  //       ),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text(
                  //             discount,
                  //             style: TextStyle(
                  //               color: AppColor.white,
                  //               fontSize: 12.sp,
                  //               fontWeight: FontWeight.w800,
                  //             ),
                  //           ),
                  //           SizedBox(width: 4.w),
                  //           SvgPicture.asset(
                  //             "assets/icons/nspah.svg",
                  //             width: 18.w,
                  //             height: 18.h,
                  //             color: Colors.white,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(height: gapH),

              // "assets/icons/motor.svg",
              if (showDelPrices)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 2.w, top: 2.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/icons/new_del.png", width: 15.w, height: 15.h, color: colorScheme.onSurface),
                            SizedBox(width: 4.w),

                            // ✅ إذا يوجد خصم توصيل (سعرين)
                            if (deliveryOldPrice != null && deliveryNewPrice != null && deliveryOldPrice != deliveryNewPrice) ...[
                              Text(
                                context.syp(deliveryOldPrice, decimals: 0),
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(width: 4.w),

                              Text(
                                context.syp(deliveryNewPrice, decimals: 0),
                                style: TextStyle(color: colorScheme.error, fontSize: 11.sp, fontWeight: FontWeight.w600),
                              ),
                            ]
                            // ✅ إذا يوجد سعر واحد فقط (لا يوجد خصم توصيل)
                            else if (deliveryNewPrice != null)
                              Text(
                                context.syp(deliveryNewPrice, decimals: 0),
                                style: TextStyle(color: colorScheme.onSurface, fontSize: 10.sp, fontWeight: FontWeight.w900),
                              ),
                          ],
                        ),
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

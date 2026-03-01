import 'dart:math' as math;

import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';

class DiscountDeliveryGridPage extends StatelessWidget {
  final List<RestaurantDiscountModel> discountDelivery;

  const DiscountDeliveryGridPage({super.key, required this.discountDelivery});

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  String _logoUrl(RestaurantDiscountModel d) =>
      UrlHelper.toFullUrl(d.logoSafe) ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "discount_delivery".tr(),
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            if (discountDelivery.isEmpty) {
              return Center(
                child: Text(
                  "no_delivery_discounts".tr(),
                  style: TextStyle(color: AppColor.white, fontSize: 14.sp),
                ),
              );
            }

            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 10.w,

                // ✅ خليه أطول شوي ليعطي مساحة للـ bottom
                childAspectRatio: 0.92,
              ),
              itemCount: discountDelivery.length,
              itemBuilder: (context, index) {
                final d = discountDelivery[index];

                final base = d.deliveryDiscount?.delivery?.baseFee ?? 0;
                final fin = d.deliveryDiscount?.delivery?.finalFee ?? 0;

                return InkWell(
                  onTap: () => openRestaurantById(context, d.restaurantId),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.black,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),

                    child: LayoutBuilder(
                      builder: (context, tile) {
                        final tileH = tile.maxHeight;

                        // ✅ الصورة تاخد ~60% من ارتفاع الكرت (وما تزيد كتير)
                        final imageH = math.min(120.h, tileH * 0.60);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r),
                              ),
                              child: Image.network(
                                _logoUrl(d),
                                height: imageH,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: imageH,
                                  // color: Colors.grey.shade800,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.store,
                                    color: Colors.white70,
                                    size: 30.sp,
                                  ),
                                ),
                              ),
                            ),

                            // ✅ الباقي ياخد المساحة المتبقية بدون overflow
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // name + rating
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            d.restaurantName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w800,
                                              fontFamily:
                                                  Localizations.localeOf(
                                                        context,
                                                      ).languageCode ==
                                                      'ar'
                                                  ? 'Cairo'
                                                  : 'Inter',
                                            ),
                                          ),
                                        ),
                                        if (d.ratingAvg > 0) ...[
                                          SizedBox(width: 6.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.30,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.10,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 12.sp,
                                                ),
                                                SizedBox(width: 3.w),
                                                Text(
                                                  d.ratingAvg.toStringAsFixed(
                                                    1,
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    const Spacer(),

                                    // delivery old/new price
                                    Row(
                                      children: [
                                        Image.asset(
                                          "assets/icons/new_del.png",
                                          color: AppColor.white,
                                          width: 15,
                                          height: 15,
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: FittedBox(
                                            alignment: Alignment.centerLeft,
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  context.syp(
                                                    base,
                                                    decimals: 0,
                                                  ),
                                                  style: TextStyle(
                                                    color: AppColor.LightActive,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  context.syp(fin, decimals: 0),
                                                  style: TextStyle(
                                                    color: AppColor.red,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Future<void> openRestaurantById(BuildContext context, int restaurantId) async {
  if (restaurantId == 0) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResturantDetails(restaurant_id: restaurantId),
    ),
  );
}

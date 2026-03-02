import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discount_card.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_delivery/discount_delivery_grid_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart'
    show CustomTitleSection;

class DiscountDeliveryHome extends StatelessWidget {
  final List<RestaurantDiscountModel> discountDelivery;

  const DiscountDeliveryHome({super.key, required this.discountDelivery});

  String _logoUrl(RestaurantDiscountModel d) =>
      UrlHelper.toFullUrl(d.logoSafe) ?? "";

  String _discountText(RestaurantDiscountModel d) {
    // ✅ prefer FOOD discount in the red badge
    final food = d.foodDiscount;
    if (food != null) {
      final type = (food.discountType ?? "").toLowerCase();
      final v = food.discountValue ?? 0;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    // ✅ fallback: DELIVERY discount if no food discount
    final del = d.deliveryDiscount;
    if (del != null) {
      final type = (del.discountType ?? "").toLowerCase();
      final v = del.discountValue ?? 0;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (discountDelivery.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: 10, start: 8, end: 0.2),
          child: SizedBox(
            height: 150.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 2.2;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: discountDelivery.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final d = discountDelivery[index];

                    final base = d.deliveryDiscount?.delivery?.baseFee;
                    final fin = d.deliveryDiscount?.delivery?.finalFee;

                    return Container(
                      width: itemWidth,
                      margin: EdgeInsetsDirectional.only(end: 10.w),
                      child: Discount(
                        isOpen: d.isOpen,
                        onTap: () =>
                            openRestaurantById(context, d.restaurantId),
                        imagePath: _logoUrl(d),
                        subtitle: d.restaurantName,
                        price: fin ?? 0,
                        discount: _discountText(d),
                        rating: d.ratingAvg,
                        ratingCount: d.ratingCount,

                        hasFoodDiscount: d.foodDiscount != null,
                        hasDeliveryDiscount: d.deliveryDiscount != null,

                        showDeliveryPrices: true,
                        deliveryOldPrice: base,
                        deliveryNewPrice: fin,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

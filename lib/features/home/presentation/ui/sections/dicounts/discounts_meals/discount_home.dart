import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/services/detect_language.dart' show extractLocalizedText;
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discount_card.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart' show ResturantDetails;
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscountHome extends StatelessWidget {
  final List<RestaurantDiscountModel> discounts;

  const DiscountHome({super.key, required this.discounts});

  String _discountText(RestaurantDiscountModel d) {
    final food = d.foodDiscount;
    if (food != null) {
      final type = food.discountType.toLowerCase();
      final v = food.discountValue;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    final del = d.deliveryDiscount;
    if (del != null) {
      final type = del.discountType.toLowerCase();
      final v = del.discountValue;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    return "";
  }

  String _logoUrl(RestaurantDiscountModel d) => UrlHelper.toFullUrl(d.logoSafe) ?? "";

  @override
  Widget build(BuildContext context) {
    if (discounts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: 10, start: 16, end: 0.2),
          child: SizedBox(
            height: 146.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 2.2;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: discounts.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final d = discounts[index];

                    final base = d.deliveryBaseFee;
                    final fin = d.deliveryFinalFee;

                    // يوجد خصم توصيل فقط إذا deliveryDiscount موجود
                    final hasDeliveryDiscount = d.deliveryDiscount != null && base != null && fin != null;
                    return Container(
                      width: itemWidth,
                      margin: EdgeInsetsDirectional.only(end: 10.w),
                      child: Discount(
                        isOpen: d.isOpen, // ✅ هون
                        onTap: () => openRestaurantById(context, d.restaurantId),
                        imagePath: _logoUrl(d),
                        // subtitle: d.restaurantName,
                        subtitle: extractLocalizedText(d.restaurantName, context.locale),
                        price: 0,
                        discount: _discountText(d),
                        rating: d.ratingAvg,
                        ratingCount: d.ratingCount,

                        // ✅ badges
                        hasFoodDiscount: d.foodDiscount != null,
                        hasDeliveryDiscount: d.deliveryDiscount != null,

                        // ✅ show delivery prices إذا موجودة
                        showDeliveryPrices: true,
                        deliveryOldPrice: hasDeliveryDiscount ? base : null,
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

class DiscountRestaurantsGridPage extends StatelessWidget {
  final List<RestaurantDiscountModel> discounts;

  const DiscountRestaurantsGridPage({super.key, required this.discounts});

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  String _logoUrl(RestaurantDiscountModel d) => UrlHelper.toFullUrl(d.logoSafe) ?? "";

  String _discountText(RestaurantDiscountModel d) {
    final food = d.foodDiscount;
    if (food != null) {
      final type = (food.discountType ?? "").toLowerCase();
      final v = food.discountValue ?? 0;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(title: "home.filters.discounts".tr(), icon: Icons.arrow_back_ios, ontap: () => Navigator.of(context).pop()),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 0.55, // More compact
                mainAxisExtent: 150.h, // More compact
              ),
              itemCount: discounts.length,
              itemBuilder: (context, index) {
                final d = discounts[index];
                final base = d.deliveryBaseFee;
                final fin = d.deliveryFinalFee;

                // يوجد خصم توصيل فقط إذا deliveryDiscount موجود
                final hasDeliveryDiscount = d.deliveryDiscount != null && base != null && fin != null;

                return Discount(
                  isOpen: d.isOpen,
                  onTap: () => openRestaurantById(context, d.restaurantId),
                  imagePath: _logoUrl(d),
                  subtitle: d.restaurantName,
                  price: 0,
                  discount: _discountText(d),
                  rating: d.ratingAvg > 0 ? d.ratingAvg : 4.5, // Default rating if 0
                  ratingCount: d.ratingCount > 0 ? d.ratingCount : 100, // Default count if 0
                  hasFoodDiscount: d.foodDiscount != null,
                  hasDeliveryDiscount: d.deliveryDiscount != null,
                  showDeliveryPrices: true,
                  deliveryOldPrice: hasDeliveryDiscount ? base : null,
                  deliveryNewPrice: fin,
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
  await Navigator.push(context, MaterialPageRoute(builder: (_) => ResturantDetails(restaurant_id: restaurantId)));
}

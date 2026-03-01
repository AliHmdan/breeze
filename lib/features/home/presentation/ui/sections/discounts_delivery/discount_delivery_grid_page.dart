import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discount_card.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart'
    show ResturantDetails;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscountDeliveryGridPage extends StatelessWidget {
  final List<RestaurantDiscountModel> discountDelivery;

  const DiscountDeliveryGridPage({super.key, required this.discountDelivery});

  String _logoUrl(RestaurantDiscountModel d) =>
      UrlHelper.toFullUrl(d.logo) ?? "";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Delivery Discounts",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(
              MediaQuery.of(context).size.width,
            ),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.58, // Adjusted for better rating display
          ),
          itemCount: discountDelivery.length,
          itemBuilder: (context, index) {
            final d = discountDelivery[index];
            final base = d.deliveryBaseFee;
            final fin = d.deliveryFinalFee;

            // يوجد خصم توصيل فقط إذا deliveryDiscount موجود
            final hasDeliveryDiscount =
                d.deliveryDiscount != null && base != null && fin != null;

            return Discount(
              isOpen: d.isOpen,
              onTap: () => openRestaurantById(context, d.restaurantId),
              imagePath: _logoUrl(d),
              subtitle: d.restaurantName,
              price: 0,
              discount: _discountText(d),
              rating: d.ratingAvg > 0
                  ? d.ratingAvg
                  : 4.5, // Default rating if 0
              ratingCount: d.ratingCount > 0
                  ? d.ratingCount
                  : 100, // Default count if 0
              hasFoodDiscount: false, // Only delivery discount
              hasDeliveryDiscount: d.deliveryDiscount != null,
              showDeliveryPrices: true,
              deliveryOldPrice: hasDeliveryDiscount ? base : null,
              deliveryNewPrice: fin,
            );
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  String _discountText(RestaurantDiscountModel d) {
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

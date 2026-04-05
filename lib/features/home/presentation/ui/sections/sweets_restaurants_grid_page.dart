import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/app/bloc/app_cubit.dart' show AppCubit;
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discount_card.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart' show ResturantDetails;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SweetsRestaurantsGridPage extends StatelessWidget {
  final List<HomeRestaurantModel> restaurants;
  final String? screenTitle;

  const SweetsRestaurantsGridPage({super.key, required this.restaurants, this.screenTitle});

  String _logoUrl(HomeRestaurantModel r) => r.logoUrl ?? "";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = AppCubit.get(context).isThemDark();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.Dark,

        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // icons color
      ),
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomAppbarProfile(title: screenTitle ?? "Sweets", icon: Icons.arrow_back_ios, ontap: () => Navigator.of(context).pop()),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(MediaQuery.of(context).size.width),
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.55, // More compact
              mainAxisExtent: 150.h,
            ),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final r = restaurants[index];

              return Discount(
                isOpen: r.isOpen,
                onTap: () => openRestaurantById(context, r.id),
                imagePath: _logoUrl(r),
                subtitle: r.name,
                price: 0,
                discount: "", // No discount for regular restaurants
                rating: r.ratingAvg > 0 ? r.ratingAvg : 4.5, // Default rating if 0
                ratingCount: r.ratingCount > 0 ? r.ratingCount : 100, // Default count if 0
                hasFoodDiscount: false,
                hasDeliveryDiscount: false,
                showDeliveryPrices: true, // Show delivery prices for restaurants
                deliveryOldPrice: r.deliveryBaseFee > 0 ? r.deliveryBaseFee : null,
                deliveryNewPrice: r.deliveryFinalFee,
              );
            },
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }
}

Future<void> openRestaurantById(BuildContext context, int restaurantId) async {
  if (restaurantId == 0) return;
  await Navigator.push(context, MaterialPageRoute(builder: (_) => ResturantDetails(restaurant_id: restaurantId)));
}

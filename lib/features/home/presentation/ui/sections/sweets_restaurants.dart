import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/detect_language.dart'
    show extractLocalizedText;
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/open_status_badge.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SweetsRestaurantCard extends StatefulWidget {
  final String? image;
  final String name;
  final double rating;
  final double? deliveryFee;
  final bool isOpen; // ✅
  final bool hasFoodDiscount; // ✅ NEW
  final String discount; // ✅ NEW
  final VoidCallback? onTap;

  const SweetsRestaurantCard({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.deliveryFee,
    required this.isOpen, // ✅
    this.hasFoodDiscount = false, // ✅ NEW
    this.discount = '', // ✅ NEW
    this.onTap,
  });

  @override
  State<SweetsRestaurantCard> createState() => _SweetsRestaurantCardState();
}

class _SweetsRestaurantCardState extends State<SweetsRestaurantCard> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    final feeText = (widget.deliveryFee != null && widget.deliveryFee! > 0)
        ? context.syp(widget.deliveryFee, decimals: 0)
        : "common.dash".tr();

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AppNetworkImage(
                  path: widget.image,
                  height: 100.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fallback: Image.asset(
                    "assets/images/meal_breeze.jpeg",
                    height: 100.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ✅ Closed overlay (نفس الفطور)
              if (!widget.isOpen) const ClosedOverlay(),

              // ✅ Discount badge
              if (widget.hasFoodDiscount && widget.discount.trim().isNotEmpty)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.red,
                      borderRadius: BorderRadiusDirectional.only(
                        // topStart:  Radius.circular(12.r),
                        bottomStart: Radius.circular(12.r),
                        topEnd: Radius.circular(20.r),
                        bottomEnd: Radius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.discount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        // SvgPicture.asset(
                        //   "assets/icons/nspah.svg",
                        //   width: 18.w,
                        //   height: 18.h,
                        //   color: Colors.white,
                        // ),
                      ],
                    ),
                  ),
                ),

              // Rating ()
              PositionedDirectional(
                top: 6,
                end: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.inverseSurface.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 12.sp),
                      SizedBox(width: 3.w),
                      Text(
                        _rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'Cairo'
                              : 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: Text(
              // widget.name,
              extractLocalizedText(widget.name, context.locale),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'Cairo'
                    : 'Inter',
              ),
            ),
          ),
          SizedBox(height: 1.h),

          Row(
            children: [
              Image.asset(
                "assets/icons/new_del.png",
                width: 15.w,
                height: 15.h,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 4.w),
              Text(
                context.syp(feeText, decimals: 0),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily:
                      Localizations.localeOf(context).languageCode == 'ar'
                      ? 'Cairo'
                      : 'Inter',
                ),
              ),

              // CustomSubTitle(
              //   subtitle: feeText,
              //   color: AppColor.white,
              //   fontsize: 12.sp,
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class SweetsRestaurantsSection extends StatelessWidget {
  final List<HomeRestaurantModel> restaurants;
  final List<RestaurantDiscountModel> discounts; // ✅ NEW
  final bool hideWhenEmpty;
  final ValueChanged<HomeRestaurantModel>? onTap;

  const SweetsRestaurantsSection({
    super.key,
    required this.restaurants,
    this.discounts = const [], // ✅ NEW
    this.hideWhenEmpty = true,
    this.onTap,
  });

  // ✅ NEW: Helper method to get discount text for a restaurant
  String _getDiscountText(HomeRestaurantModel restaurant) {
    final discount = discounts.firstWhere(
      (d) => d.restaurantId == restaurant.id,
      orElse: () => RestaurantDiscountModel(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        logo: null, // ✅ Fixed: Added required logo parameter
        isOpen: restaurant.isOpen,
        ratingAvg: restaurant.ratingAvg,
        ratingCount: 0,
        foodDiscount: null,
        deliveryDiscount: null,
      ),
    );

    if (discount.foodDiscount != null) {
      final type = discount.foodDiscount!.discountType.toLowerCase();
      final value = discount.foodDiscount!.discountValue;
      if (value <= 0) return "";
      if (type.contains('percent')) return "${value.toStringAsFixed(0)}%";
      return value.toStringAsFixed(0);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      if (hideWhenEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Container(
          height: 100.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: CustomSubTitle(
            subtitle: "home.empty_sweets".tr(), // ✅ رسالة السويتس
            color: AppColor.white,
            fontsize: 14.sp,
          ),
        ),
      );
    }

    final gap = 10.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;

    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final r = restaurants[index];

          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(
              left: index == 0 ? 9.w : 0,
              right: index == restaurants.length - 1 ? 10.w : gap,
            ),
            child: SweetsRestaurantCard(
              image: restaurantImage(r),
              isOpen: r.isOpen,
              name: r.name,
              rating: r.ratingAvg <= 0 ? 4.0 : r.ratingAvg,
              deliveryFee: r.deliveryFinalFee?.toDouble(),
              hasFoodDiscount: _getDiscountText(r).isNotEmpty, // ✅ NEW
              discount: _getDiscountText(r), // ✅ NEW
              onTap: () async {
                // ✅ إذا مررت onTap من الهوم، استخدمه
                if (onTap != null) {
                  onTap!(r);
                  return;
                }

                // ✅ fallback: نفس سلوك الفطور (يفتح تفاصيل)
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(create: (_) => getIt<FavoritesCubit>()),
                        BlocProvider.value(value: context.read<CartCubit>()),
                      ],
                      child: ResturantDetails(restaurant_id: r.id),
                    ),
                  ),
                );

                if (context.mounted) {
                  context.read<CartCubit>().loadCart(silent: true);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

String? restaurantImage(HomeRestaurantModel r) {
  final cover = (r.coverImage ?? "").trim();
  final logo = (r.logo ?? "").trim();
  final picked = cover.isNotEmpty ? cover : logo;
  return picked.isEmpty ? null : picked;
}

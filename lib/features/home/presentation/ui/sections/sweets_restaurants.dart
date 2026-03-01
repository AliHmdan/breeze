import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/prices_helper.dart';
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
  final VoidCallback? onTap;

  const SweetsRestaurantCard({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.deliveryFee,
    required this.isOpen,
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

              // Rating (نفس الفطور)
              PositionedDirectional(
                top: 6,
                end: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 3.w),
                      Text(
                        _rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
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
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'Cairo'
                    : 'Inter',
              ),
            ),
          ),
          SizedBox(height: 6.h),

          Row(
            children: [
              Image.asset(
                "assets/icons/new_del.png",
                width: 16.w,
                height: 16.h,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 4.w),
              CustomSubTitle(
                subtitle: feeText,
                color: AppColor.white,
                fontsize: 12.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SweetsRestaurantsSection extends StatelessWidget {
  final List<HomeRestaurantModel> restaurants;
  final bool hideWhenEmpty;
  final ValueChanged<HomeRestaurantModel>? onTap;

  const SweetsRestaurantsSection({
    super.key,
    required this.restaurants,
    this.hideWhenEmpty = true,
    this.onTap,
  });

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

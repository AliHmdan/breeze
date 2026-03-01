import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/breakfast_restaurants.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/open_status_badge.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CloserToYouCard extends StatefulWidget {
  final String? image;
  final String name;
  final double rating;
  final double? deliveryFee;
  final bool isOpen; // ✅ NEW
  final VoidCallback? onTap;

  const CloserToYouCard({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.deliveryFee,
    required this.isOpen, // ✅
    this.onTap,
  });

  @override
  State<CloserToYouCard> createState() => _CloserToYouCardState();
}

class _CloserToYouCardState extends State<CloserToYouCard> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    final feeText = (widget.deliveryFee != null && widget.deliveryFee! > 0)
        ? context.syp(widget.deliveryFee, decimals: 0) // ✅ هنا
        : "--";

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // ✅ Open/Closed badge
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
              if (!widget.isOpen) const ClosedOverlay(),
              PositionedDirectional(
                top: 6,
                end: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2), //   خلفية خفيفة
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: Offset(0, 1),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Name center
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
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
                color: Colors.white,
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

//////////////////////////////////////////////////////////////
// 🧩 Closer To You Section
//////////////////////////////////////////////////////////////

class CloserToYou extends StatelessWidget {
  final List<HomeRestaurantModel> restaurants;
  final bool hideWhenEmpty;

  const CloserToYou({
    super.key,
    required this.restaurants,
    this.hideWhenEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      if (hideWhenEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          height: 100.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: CustomSubTitle(
            subtitle: "No restaurants found",
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final r = restaurants[index];

          return Container(
            width: cardWidth,
            margin: EdgeInsetsDirectional.only(end: gap),
            child: CloserToYouCard(
              isOpen: r.isOpen, // ✅ هون
              image: restaurantImage(r),
              name: r.name,
              rating: r.ratingAvg <= 0 ? 4.0 : r.ratingAvg,
              deliveryFee: r.deliveryFinalFee?.toDouble(),

              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(create: (_) => getIt<FavoritesCubit>()),
                        BlocProvider(create: (_) => getIt<CartCubit>()),
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

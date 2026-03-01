import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/services/del_price_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/open_status_badge.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Supermarketslider extends StatelessWidget {
  final List<HomeRestaurantModel> restaurants;
  final void Function(dynamic r)? onTap;
  final VoidCallback? onRateSuccess;

  const Supermarketslider({
    super.key,
    required this.restaurants,
    this.onTap,
    this.onRateSuccess,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return const SizedBox.shrink();

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
            child: _SupermarketCard(
              model: r,
              onTap: onTap == null ? null : () => onTap!(r),
            ),
          );
        },
      ),
    );
  }
}

class _SupermarketCard extends StatefulWidget {
  final HomeRestaurantModel model;
  final VoidCallback? onTap;

  const _SupermarketCard({required this.model, this.onTap});

  @override
  State<_SupermarketCard> createState() => _SupermarketCardState();
}

class _SupermarketCardState extends State<_SupermarketCard> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.model.ratingAvg <= 0 ? 4.0 : widget.model.ratingAvg;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        UrlHelper.toFullUrl(widget.model.coverImage) ??
        UrlHelper.toFullUrl(widget.model.logo);

    final feeText = deliveryFeeText(widget.model);

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 الصورة
          Stack(
            children: [
              // ✅ Open/Closed badge
              AppNetworkImage(
                path: imageUrl,
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(12.r), // إذا بدك حواف
                fallback: Image.asset(
                  "assets/images/meal_breeze.jpeg", // صورتك الافتراضية
                  height: 100.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (!widget.model.isOpen)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),

                        child: CustomSubTitle(
                          subtitle: "restaurant.closed".tr(),
                          color: AppColor.white,
                          fontsize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),

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
                        offset: const Offset(0, 1),
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

          SizedBox(height: 6.h),

          /// الاسم
          Text(
            widget.model.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6.h),

          /// التوصيل
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
                color: Theme.of(context).colorScheme.onSurface,
                fontsize: 12.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/del_price_helper.dart';
import 'package:breezefood/core/services/detect_language.dart' show extractLocalizedText;
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

  const Supermarketslider({super.key, required this.restaurants, this.onTap, this.onRateSuccess});

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return const SizedBox.shrink();

    final gap = 10.w;
    final cardWidth = MediaQuery.of(context).size.width / 2.3;

    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        padding: EdgeInsetsDirectional.only(start: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: restaurants.length,

        itemBuilder: (context, index) {
          final r = restaurants[index];

          return Container(
            width: cardWidth,
            margin: EdgeInsetsDirectional.only(end: gap),
            child: _SupermarketCard(model: r, onTap: onTap == null ? null : () => onTap!(r)),
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
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = UrlHelper.toFullUrl(widget.model.coverImage) ?? UrlHelper.toFullUrl(widget.model.logo);

    final feeText = deliveryFeeText(widget.model);

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 الصورة
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r), // نفس الخصومات
                child: AspectRatio(
                  aspectRatio: 16 / 9, //
                  child: AppNetworkImage(
                    path: imageUrl,
                    height: 100.h, // نفس ارتفاع الصورة
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fallback: Image.asset("assets/images/meal_breeze.jpeg", fit: BoxFit.cover),
                  ),
                ),
              ),
              if (!widget.model.isOpen)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: colorScheme.inverseSurface.withOpacity(0.45), borderRadius: BorderRadius.circular(12.r)),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),

                        child: CustomSubTitle(subtitle: "restaurant.closed".tr(), color: AppColor.red, fontsize: 13.sp),
                      ),
                    ),
                  ),
                ),

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
                        _rating.toStringAsFixed(1),
                        style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 0.h), // نفس gapH الطبيعي
          // 🏷️ Name (center مثل Discount)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: Text(
              // widget.model.name,
              extractLocalizedText(widget.model.name, context.locale),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(color: AppColor.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
          ),

          SizedBox(height: 1.h),

          // 🚚 Delivery row بنفس padding الداخلي
          Padding(
            padding: EdgeInsetsDirectional.only(start: 0.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/icons/new_del.png", width: 15.w, height: 15.h, color: AppColor.white.withOpacity(0.7)),
                SizedBox(width: 4.w),
                Text(
                  context.syp(feeText, decimals: 0),
                  // feeText,
                  style: TextStyle(color: AppColor.white.withOpacity(0.7), fontSize: 11.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

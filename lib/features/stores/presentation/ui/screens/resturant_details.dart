import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';

import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';

import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';

import 'package:breezefood/features/stores/model/restaurant_details_model.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscountItemCard extends StatelessWidget {
  final MenuItem item;
  final String imageUrl;

  const DiscountItemCard({
    super.key,
    required this.item,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final title = context.pick(ar: item.nameAr, en: item.nameEn);
    final before = item.priceBefore > 0 ? item.priceBefore : item.price;
    final after = item.effectivePrice;
    final hasDiscount = item.hasDiscount && after < before;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(11.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: 145.h,
                height: 145.h,
                child: AppNetworkImage(
                  path: imageUrl,
                  height: 145.h,
                  width: 145.h,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(16.r),
                  fallback: _fallback(),
                ),
              ),
              if (item.discountPercent > 0)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.red,
                      borderRadius: BorderRadiusDirectional.only(
                        topEnd: Radius.circular(20.r),
                        bottomEnd: Radius.circular(20.r),
                        bottomStart: Radius.circular(25.r),
                      ),
                    ),
                    child: CustomSubTitle(
                      subtitle: "-${item.discountPercent.toStringAsFixed(0)}%",
                      color: Colors.white,
                      fontsize: 11.sp,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            height: 55.h,
            width: 145.h,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
                ),
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        context.money(before, decimals: 0),
                        style: TextStyle(
                          color: AppColor.LightActive,
                          fontSize: 11.sp,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColor.LightActive,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'Cairo'
                              : 'Inter',
                        ),
                      ),
                      const SizedBox(width: 4),
                      CustomSubTitle(
                        subtitle: context.money(after, decimals: 0),
                        color: AppColor.red,
                        fontsize: 12.sp,
                      ),
                    ] else ...[
                      CustomSubTitle(
                        subtitle: context.money(after, decimals: 0),
                        color: AppColor.white,
                        fontsize: 12.sp,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 26),
    );
  }
}

String buildDiscountBadge(MenuItemModel item, BuildContext context) {
  if (!item.hasDiscount) return "";
  final type = item.discountType ?? "percentage";
  final v = item.discountValue ?? 0;

  if (type == "fixed") {
    return "-${context.money(v, decimals: 0)}";
  }
  return "-${v.toStringAsFixed(0)}%";
}

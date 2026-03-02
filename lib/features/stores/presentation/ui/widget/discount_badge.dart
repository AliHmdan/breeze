import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/prices_helper.dart';

// ✅ Badge الخصم: يظهر فقط إذا hasDiscount
class DiscountBadge extends StatelessWidget {
  final bool hasDiscount;
  final double percent;

  const DiscountBadge({
    super.key,
    required this.hasDiscount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasDiscount || percent <= 0) return const SizedBox.shrink();

    return PositionedDirectional(
      bottom: 0,
      start: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(20.r),
            bottomEnd: Radius.circular(20.r),
          ),
        ),
        child: Text(
          "-${percent.toStringAsFixed(0)}%",
          style: TextStyle(
            color: AppColor.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ✅ سطر السعر: إذا في خصم يعرض قبل/بعد، إذا لا يعرض سعر واحد
class PriceLine extends StatelessWidget {
  final num price;
  final num priceBefore;
  final bool hasDiscount;

  const PriceLine({
    super.key,
    required this.price,
    required this.priceBefore,
    required this.hasDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final before = (priceBefore > 0) ? priceBefore : price;

    if (!hasDiscount) {
      return Text(
        context.syp(price, decimals: 0),
        style: TextStyle(
          color: AppColor.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Row(
      children: [
        Text(
          context.syp(before, decimals: 0),
          style: TextStyle(
            color: AppColor.LightActive,
            fontSize: 11.sp,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          context.syp(price, decimals: 0),
          style: TextStyle(
            color: AppColor.red,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QtyCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  final num? pricePerItem;
  final int moneyDecimals;

  const QtyCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.pricePerItem,
    this.moneyDecimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalNum = (pricePerItem == null) ? null : (value * pricePerItem!);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// 🔹 Counter Container
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(40.r), // pill shape
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ➖ Decrease
              GestureDetector(
                onTap: value > 1 ? () => onChanged(value - 1) : null,
                child: Icon(
                  Icons.remove,
                  size: 26.sp,
                  color: isDark ? Colors.white : AppColor.lightblack,
                ),
              ),

              SizedBox(width: 25.w),

              /// 🔢 Value
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              SizedBox(width: 25.w),

              /// ➕ Increase
              GestureDetector(
                onTap: () => onChanged(value + 1),
                child: Icon(
                  Icons.add,
                  size: 26.sp,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),

        /// 💰 Total Price (optional)
        if (totalNum != null) ...[
          SizedBox(width: 12.w),
          Text(
            context.money(totalNum, decimals: moneyDecimals),
            style: TextStyle(
              color: AppColor.yellow,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

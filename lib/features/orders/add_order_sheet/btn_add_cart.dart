import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddToCartButton extends StatelessWidget {
  final bool isLoading;
  final bool isRestaurantOpen;
  final double total;
  final int count;
  final ValueChanged<int> onAdd;

  const AddToCartButton({
    super.key,
    required this.isLoading,
    required this.isRestaurantOpen,
    required this.total,
    required this.count,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final baseDisabled = isLoading || !isRestaurantOpen;
    final btnText = "common.AddToCart".tr();

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: baseDisabled ? null : () => onAdd(count),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      btnText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    context.syp(total),
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

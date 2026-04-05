import 'dart:ui';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClosedOverlay extends StatelessWidget {
  const ClosedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(color: colorScheme.inverseSurface.withOpacity(0.45), borderRadius: BorderRadius.circular(12.r)),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),

            child: CustomSubTitle(subtitle: "restaurant.closed".tr(), color: AppColor.red, fontsize: 13.sp),
          ),
        ),
      ),
    );
  }
}

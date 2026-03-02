import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const CustomButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                ? 'Cairo'
                : 'Inter',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

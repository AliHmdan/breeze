import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomButtonOrder extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const CustomButtonOrder({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        width: double.infinity,
        height: 44.h,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            backgroundColor: AppColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.r),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // ✅ يمنع أخذ عرض كامل
            children: [
              SvgPicture.asset(
                'assets/icons/box.svg',
                width: 20.w,
                height: 20.h,
                color: Colors.white,
              ),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

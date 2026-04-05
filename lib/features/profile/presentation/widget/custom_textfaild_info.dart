import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextfaildInfo extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  const CustomTextfaildInfo({super.key, required this.label, required this.hint, this.controller, required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      style: TextStyle(color: AppColor.white),

      decoration: InputDecoration(
        // labelText: label,
        labelStyle: TextStyle(color: AppColor.primaryColor, fontSize: 14.sp, fontFamily: "Monrope"),
        alignLabelWithHint: false,
        floatingLabelAlignment: FloatingLabelAlignment.start,

        hintText: hint,
        helperStyle: TextStyle(color: AppColor.Dark, fontSize: 14.sp, fontFamily: "Monrope"),
        filled: true,
        fillColor: AppColor.search,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),

        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
      ),
    );
  }
}

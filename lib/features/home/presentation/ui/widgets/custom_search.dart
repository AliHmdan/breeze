import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomSearch extends StatelessWidget {
  final IconData? icon;
  final String? hint;
  final String? boxicon;
  final void Function()? onTap;
  final bool readOnly;
  final double height;
  final double borderRadius;

  const CustomSearch({super.key, this.hint, this.icon, this.boxicon, this.onTap, this.readOnly = true, this.height = 40, this.borderRadius = 30});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (icon != null)
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(50.r)),
            child: IconButton(
              icon: Icon(
                icon,
                color: AppColor.white,
                size: 18.sp, // ✅ متجاوب
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        SizedBox(width: 8.w),
        Expanded(
          child: SizedBox(
            height: height.h,
            child: TextFormField(
              readOnly: readOnly,
              onTap: onTap,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.2, // ✅ توازن النص داخل الحقل
                color: AppColor.white,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  // color: AppColor.white.withOpacity(0.65),
                  // color: AppColor.white,
                  color: AppColor.white.withOpacity(0.55),
                  fontSize: 14.sp,
                  fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter',
                ),

                prefixIcon: Padding(
                  padding: EdgeInsetsDirectional.only(top: 10.w, bottom: 10.w, start: 140.w), //تحكم بحجم الأيقونة
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                    // color: colorScheme.onSurface.withOpacity(0.65),
                    // color: AppColor.white,
                    color: AppColor.white.withOpacity(0.55),
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
                // ✅ هذه أهم نقطة لضبط الارتفاع
                contentPadding: EdgeInsets.symmetric(
                  vertical: (height / 2.8).h, // تناسب ديناميكي
                  horizontal: 12.w,
                ),
                filled: true,
                fillColor: AppColor.Dark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide(
                    color: Colors.transparent, // أخضر عند الفوكس
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius.r), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),

                  borderSide: BorderSide(
                    // color: colorScheme.primary, // أخضر عند الفوكس
                    color: Colors.transparent,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 5.w),
        if (boxicon != null)
          Container(
            width: 30.w,
            height: 30.w, // الأفضل جعلها مربعة لضمان دائرة صحيحة
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle, // 👈 دائرة كاملة
            ),
            child: SvgPicture.asset(boxicon!, width: 20.w, height: 20.w),
          ),
      ],
    );
  }
}

import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppbarProfile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundcolor;
  final VoidCallback ontap;

  const CustomAppbarProfile({
    super.key,
    this.icon,
    this.subtitle,
    this.title,
    required this.ontap,
    this.backgroundcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 30),
      child: SizedBox(
        height: 48.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // / 🔙 زر الرجوع (يسار)
            if (icon != null)
              PositionedDirectional(
                start: 0,
                child: GestureDetector(
                  onTap: ontap,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      // color: Theme.of(context).brightness == Brightness.dark
                      //     ? Colors.black
                      //     : Colors.white,
                      shape: BoxShape.circle,
                      // border: Border.all(width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 6),
                      child: Icon(
                        icon,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),

            /// 🏷️ العنوان (في منتصف الشاشة تمامًا)
            if (title != null)
              Center(
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.white,
                    fontFamily:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

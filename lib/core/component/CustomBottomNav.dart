import 'package:breezefood/core/component/color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBreeze extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BottomNavBreeze({super.key, required this.currentIndex, required this.onChanged});

  static const List<String> _iconsOutline = [
    'assets/icons/home-linear.svg',
    'assets/icons/favorite.svg',
    'assets/icons/ordernav.svg',
    'assets/icons/profile.svg',
  ];

  static const List<String> _iconsFilled = [
    'assets/icons/home-filled.svg',
    'assets/icons/favorite-filled.svg',
    'assets/icons/order_filled.svg',
    'assets/icons/profile-filled.svg',
  ];

  static const List<String> _labelKeys = ["nav.home", "nav.favorites", "nav.orders", "nav.Profile"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: context.locale == "en" ? 60.h : 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_iconsOutline.length, (index) {
            final isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon without background container
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: SvgPicture.asset(
                          isSelected ? _iconsFilled[index] : _iconsOutline[index],
                          key: ValueKey('${isSelected}_$index'),
                          width: 24.sp,
                          height: 24.sp,
                          colorFilter: ColorFilter.mode(
                            isSelected ? Theme.of(context).colorScheme.onSurface : AppColor.gry.withOpacity(0.7),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Label with WhatsApp-style text
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: isSelected ? 12.sp : 11.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Theme.of(context).colorScheme.onSurface : AppColor.gry.withOpacity(0.7),
                          fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter',
                        ),
                        child: Text(_labelKeys[index].tr()),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

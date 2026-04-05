import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void configEasyLoading() {
  EasyLoading.instance
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..loadingStyle = EasyLoadingStyle.custom
    // ألوان
    ..indicatorColor = AppColor.primaryColor
    ..backgroundColor = AppColor.white
    ..textColor = AppColor.black.withOpacity(0.85)
    ..boxShadow = const [BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Colors.black12)]
    // Mask
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = Colors.black.withOpacity(0.25)
    ..userInteractions = false
    ..dismissOnTap = false
    // شكل
    ..radius = 22
    ..contentPadding = const EdgeInsets.symmetric(horizontal: 22, vertical: 18)
    // نص
    ..fontSize = 14.5
    ..textStyle = TextStyle(fontFamily: "Almarai", fontWeight: FontWeight.w600, color: AppColor.black.withOpacity(0.85), height: 1.3)
    // Indicator مخصص
    ..indicatorWidget = const _BreezeLoadingIndicator()
    ..indicatorSize = 0
    ..displayDuration = const Duration(milliseconds: 1200);
}

class _BreezeLoadingIndicator extends StatelessWidget {
  const _BreezeLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CircularProgressIndicator(
        strokeWidth: 3.2,
        valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
        backgroundColor: AppColor.light,
        color: AppColor.primaryColor, // أو AppColor.gry
      ),
    );
  }
}

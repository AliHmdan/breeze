import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:breezefood/core/router/navigation_key.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';

class AppDialog {
  static Future<void> showErrorDialog(String title, String message) {
    return showDialog(
      context: NavigationKey.context,
      barrierDismissible: true,
      barrierColor: AppColor.black.withOpacity(0.45),
      builder: (_) => _BreezeDialogShell(
        icon: Iconsax.warning_2,
        iconColor: AppColor.red,
        title: title,
        message: message,
        actions: CustomButton(title: 'حسناً', onPressed: () => Navigator.pop(NavigationKey.context)),
      ),
    );
  }

  static Future<void> showSuccessDialog({String title = "تمت العملية بنجاح", String message = ""}) {
    return showDialog(
      context: NavigationKey.context,
      barrierDismissible: true,
      barrierColor: AppColor.black.withOpacity(0.45),
      builder: (_) => _BreezeDialogShell(
        icon: Iconsax.tick_circle,
        iconColor: AppColor.green,
        title: title,
        message: message,
        actions: CustomButton(title: 'موافق', onPressed: () => Navigator.pop(NavigationKey.context)),
      ),
    );
  }

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String yesText = "تأكيد",
    String noText = "إلغاء",
    IconData icon = Iconsax.trash,
    Color? iconColor,
  }) {
    final c = iconColor ?? AppColor.yellow;

    return showDialog<bool>(
      context: NavigationKey.context,
      barrierDismissible: true,
      barrierColor: AppColor.black.withOpacity(0.45),
      builder: (_) => _BreezeDialogShell(
        icon: icon,
        iconColor: c,
        title: title,
        message: message,
        actions: Row(
          children: [
            Expanded(
              child: CustomButton(
                title: noText,
                // إذا زرّك بيدعم تخصيص ألوان
                onPressed: () => Navigator.pop(NavigationKey.context, false),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomButton(title: yesText, onPressed: () => Navigator.pop(NavigationKey.context, true)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreezeDialogShell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget actions;

  const _BreezeDialogShell({required this.icon, required this.iconColor, required this.title, required this.message, required this.actions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.Dark,
      contentPadding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          SizedBox(height: 18.h),

          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColor.white),
            textAlign: TextAlign.center,
          ),

          if (message.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColor.white.withOpacity(0.75)),
              textAlign: TextAlign.center,
            ),
          ],

          SizedBox(height: 24.h),
          actions,
        ],
      ),
    );
  }
}

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/restart_widget.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  String selected = "en";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ آمن هون لأن الـ InheritedWidgets صارت جاهزة
    selected = context.locale.languageCode;
  }

  Future<void> _setLang(String code) async {
    if (selected == code) return;

    setState(() => selected = code);

    await context.setLocale(Locale(code));

    // ✅ Restart ناعم حتى يتطبق كلشي (RTL/LTR + خطوط + UI)
    // RestartWidget.restartApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(60.h),
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 16.w),
        //     child: CustomAppbarProfile(title: "language".tr(), icon: Icons.arrow_back_ios, ontap: () => Navigator.pop(context)),
        //   ),
        // ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                CustomAppbarProfile(title: "profile.language".tr(), icon: Icons.arrow_back_ios, ontap: () => Navigator.pop(context)),
                SizedBox(height: 15.h),
                _LangButton(label: "profile.english".tr(), active: selected == "en", onTap: () => _setLang("en")),
                SizedBox(height: 12.h),
                _LangButton(label: "profile.arabic".tr(), active: selected == "ar", onTap: () => _setLang("ar")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _LangButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(color: active ? AppColor.primaryColor : Colors.grey[800], borderRadius: BorderRadius.circular(12.r)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

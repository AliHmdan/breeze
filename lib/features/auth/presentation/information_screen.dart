import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breezefood/features/auth/presentation/update_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  bool _isLoading = false;

  late final AuthFlowCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
  }

  void _saveInformation() {
    final first = firstnameController.text.trim();
    final last = lastnameController.text.trim();

    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('auth.enter_first_last'.tr())));
      return;
    }

    cubit.updateProfile(firstName: first, lastName: last);
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: AppColor.primaryColor,
        style: TextStyle(color: AppColor.white, fontSize: 16.sp),

        //  ممنوع الأرقام
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zء-ي\s]')),
        ],

        //  validation
        validator: (v) {
          final val = (v ?? '').trim();

          if (val.isEmpty) {
            return "يرجى إدخال النص";
          }

          if (val.length < 3) {
            return "يجب أن يحتوي على 3 أحرف على الأقل";
          }

          if (!RegExp(r'^[a-zA-Zء-ي\s]+$').hasMatch(val)) {
            return "يسمح بإدخال الأحرف فقط";
          }

          return null;
        },

        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 16.sp,
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocListener<AuthFlowCubit, AuthFlowState>(
      bloc: cubit,
      listener: (context, state) {
        state.whenOrNull(
          loading: () => EasyLoading.show(status: "common.saving".tr()),
          error: (msg) {
            EasyLoading.dismiss();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.tr()), backgroundColor: colorScheme.error));
          },
          profileUpdated: (_) {
            EasyLoading.dismiss();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UpdateAddressScreen()));
          },
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "assets/images/background_auth.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: colorScheme.surface,
                alignment: Alignment.center,
                child: Text("common.placeholder".tr(), style: TextStyle(color: colorScheme.onSurface)),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.outline.withOpacity(0.35)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 16.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "auth.enter_info_title".tr(),
                      style: TextStyle(fontSize: 18.sp, color: colorScheme.onSurface, fontFamily: "Manrope", fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 35.h),
                    _buildTextField(hint: "auth.first_name".tr(), controller: firstnameController),
                    SizedBox(height: 20.h),
                    _buildTextField(hint: "auth.last_name".tr(), controller: lastnameController),
                    SizedBox(height: 30.h),
                    InkWell(
                      onTap: _isLoading ? null : _saveInformation,
                      child: Container(
                        width: double.infinity,
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: _isLoading ? colorScheme.onSurface.withOpacity(0.35) : AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? CircularProgressIndicator(color: AppColor.primaryColor)
                            : Text(
                          "common.save".tr(),
                          style: TextStyle(fontSize: 16.sp, color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

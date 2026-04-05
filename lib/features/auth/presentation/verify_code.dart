import 'dart:async';
import 'package:breezefood/core/component/color.dart' show AppColor;
import 'package:breezefood/features/auth/presentation/information_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:easy_localization/easy_localization.dart';

class VerfiyCode extends StatefulWidget {
  final String phone;
  const VerfiyCode({super.key, required this.phone});

  @override
  State<VerfiyCode> createState() => _VerfiyCodeState();
}

class _VerfiyCodeState extends State<VerfiyCode> {
  late final AuthFlowCubit cubit;

  bool _isResending = false;
  bool _isVerifying = false; // ✅ لمنع double submit
  String? _message;
  Color _messageColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  void _verifyCode(String code) {
    final c = code.trim();
    if (c.length != 4) return;
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _message = null;
    });

    cubit.verify(phone: widget.phone, code: c);
  }

  void _resendCode() {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _message = null;
    });

    cubit.resend(phone: widget.phone);
  }

  void _showSuccess(String msg) {
    setState(() {
      _message = msg;
      _messageColor = Colors.greenAccent;
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _showError(String msg) {
    setState(() {
      _message = msg;
      _messageColor = Colors.redAccent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<AuthFlowCubit, AuthFlowState>(
        bloc: cubit,
        listener: (context, state) {
          state.whenOrNull(
            loading: () => EasyLoading.show(status: "auth.verifying".tr()),
            error: (msg) {
              EasyLoading.dismiss();
              if (mounted) {
                setState(() {
                  _isVerifying = false;
                  _isResending = false;
                });
              }
              _showError(msg.tr());
            },
            codeResent: (data) {
              EasyLoading.dismiss();
              if (mounted) setState(() => _isResending = false);

              final msg = (data is Map) ? (data["message"] ?? "auth.code_sent".tr()) : "auth.code_sent".tr();
              _showSuccess(msg.toString());
            },
            verified: (data) {
              EasyLoading.dismiss();
              if (mounted) setState(() => _isVerifying = false);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InformationScreen()));
            },
          );
        },
        child: Stack(
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
              child: Padding(
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
                          padding: EdgeInsetsDirectional.only(start: 5),
                          child: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 16.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "auth.enter_code_title".tr(),
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "auth.enter_code_hint".tr(args: [widget.phone]),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 45.h),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: PinCodeTextField(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        appContext: context,
                        length: 4,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 70,
                          fieldWidth: 70,
                          activeColor: AppColor.primaryColor,
                          selectedColor: AppColor.primaryColor,
                          inactiveColor: AppColor.primaryColor.withOpacity(0.5),
                          activeBorderWidth: 4,
                          selectedBorderWidth: 4,
                          inactiveBorderWidth: 4,
                          activeFillColor: AppColor.search,
                          selectedFillColor: AppColor.search,
                          inactiveFillColor: AppColor.search,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        enabled: !_isVerifying,
                        onCompleted: _verifyCode,
                        onChanged: (_) {},
                        textStyle: TextStyle(color: colorScheme.onSurface, fontSize: 18.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (_message != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Text(
                          _message!,
                          style: TextStyle(fontSize: 14.sp, color: _messageColor),
                        ),
                      ),
                    SizedBox(height: 20.h),
                    InkWell(
                      onTap: (_isResending || _isVerifying) ? null : _resendCode,
                      child: Text(
                        _isResending ? "common.sending".tr() : "auth.resend_code".tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w400,
                          color: (_isResending || _isVerifying) ? AppColor.primaryColor.withOpacity(0.5) : AppColor.primaryColor,
                        ),
                      ),
                    ),
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

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breezefood/features/auth/presentation/verify_code.dart';
import 'package:breezefood/features/auth/presentation/ui/terms.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AuthFlowCubit cubit;
  late final VideoPlayerController _videoController;

  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    cubit = getIt<AuthFlowCubit>();

    _videoController = VideoPlayerController.asset("assets/video/login.mp4")
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController.play();
        }
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_videoController.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      _videoController.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoController.play();
    }
  }

  String trOrRaw(String s) {
    final k = s.trim();
    if (k.isEmpty) return k;
    final looksLikeKey = k.contains('.') || k.contains('_');
    if (!looksLikeKey) return k;
    final translated = k.tr();
    return translated == k ? k : translated;
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    Color? background,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: colorScheme.onInverseSurface),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: background ?? colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openTermsAndMaybeAccept() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TermsDialog(),
    );
  }

  void _handleLogin() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      _showSnackBar(
        context,
        message: "auth.check_required_fields".tr(),
        background: AppColor.primaryColor,
        icon: Icons.info_outline,
      );
      return;
    }

    if (!_acceptedTerms) {
      _showSnackBar(
        context,
        message: "terms.must_accept".tr(),
        background: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    final phone = "+963${phoneController.text.trim()}";
    cubit.sendCode(phone: phone); // 🔥 هون إرسال الكود
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthFlowCubit, AuthFlowState>(
      bloc: cubit,
      listener: (context, state) {
        state.whenOrNull(
          loading: () => EasyLoading.show(status: "common.loading".tr()),
          error: (msg) {
            EasyLoading.dismiss();
            _showSnackBar(
              context,
              message: trOrRaw(msg), // ✅ هون الإصلاح
              background: Colors.redAccent,
              icon: Icons.error_outline,
            );
          },
          codeSent: (data) {
            EasyLoading.dismiss();

            final phone = "+963${phoneController.text.trim()}";
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VerfiyCode(phone: phone)),
            );

            final msg = (data is Map)
                ? (data["message"]?.toString() ?? "auth.code_sent".tr())
                : "auth.code_sent".tr();

            _showSnackBar(
              context,
              message: "auth.code_sent".tr(),
              background: AppColor.primaryColor,
              icon: Icons.check_circle_outline,
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            /// 🎬 VIDEO (58%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.75,
              child: _videoController.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : const SizedBox(),
            ),

            /// 🔥 PROFESSIONAL FADE BETWEEN VIDEO & CARD
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height,
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Colors.green.withOpacity(0.2),
            //         Colors.black.withOpacity(0.8),
            //         Colors.black.withOpacity(0.8),
            //         Colors.green.withOpacity(0.9),
            //       ],
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //     ),
            //   ),
            // ),
            /// 🎬 FADE FROM BOTTOM (WOLT STYLE)
            Positioned(
              left: 0,
              right: 0,
              bottom: screenHeight * 0.45,
              height: screenHeight * 0.40,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surface.withOpacity(0.92),
                        colorScheme.surface.withOpacity(0.65),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            /// 🖼 PNG IMAGE ABOVE SHADOW
            Positioned(
              left: 0,
              right: 0,
              bottom: screenHeight * 0.35, // عدلها حسب المكان اللي بدك ياه
              child: IgnorePointer(
                child: Center(
                  child: Image.asset(
                    "assets/images/logo-removebg.png",
                    width: screenHeight * 0.40, // حجم مرن
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// 📦 FLOATING CARD
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: screenHeight * 0.50,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(34.r),
                  //   topRight: Radius.circular(34.r),
                  // ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.12),
                      blurRadius: 40,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 32.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // /// 🔷 LOGO STYLE LIKE WOLT
                                  // Center(
                                  //   child: Padding(
                                  //     padding: EdgeInsets.only(bottom: 12.h),
                                  //     child: Image.asset(
                                  //       "assets/images/logo-removebg.png",
                                  //       height: 28.h, // حجم ثابت أنعم
                                  //       fit: BoxFit.contain,
                                  //     ),
                                  //   ),
                                  // ),
                                  CustomTitle(
                                    title: "auth.welcome_title".tr(),
                                    color: colorScheme.onSurface,
                                  ),
                                  SizedBox(height: 2.h),
                                  CustomSubTitle(
                                    subtitle: "auth.login_hint".tr(),
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                    fontsize: 12.sp,
                                  ),
                                  SizedBox(height: 32.h),

                                  // Phone
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.outline
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/icons/syria.png',
                                              width: 24.w,
                                              height: 24.h,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              '+963',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: _CustomTextFormField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.number,
                                          hintText: "auth.phone_number".tr(),
                                          validator: (v) {
                                            final val = (v ?? '').trim();
                                            if (val.isEmpty) {
                                              return "auth.enter_phone".tr();
                                            }
                                            if (val.length < 8) {
                                              return "auth.invalid_phone".tr();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 14.h),

                                  // Terms checkbox + tap to view
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _acceptedTerms,
                                        activeColor: colorScheme.primary,
                                        onChanged: (v) {
                                          setState(
                                            () => _acceptedTerms = v ?? false,
                                          ); // ✅ قبول مباشر بدون فتح الديالوج
                                        },
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap:
                                              _openTermsAndMaybeAccept, // ✅ هون بس فتح الديالوج للعرض
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 12.h),
                                            child: Text(
                                              "terms.tap_to_view_and_accept"
                                                  .tr(),
                                              style: TextStyle(
                                                color: colorScheme.onSurface,
                                                fontSize: 12.sp,
                                                height: 1.4,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: colorScheme
                                                    .onSurface
                                                    .withOpacity(0.35),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 24.h),

                                  // Continue button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55.h,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(15.r),
                                      onTap: _acceptedTerms
                                          ? _handleLogin
                                          : () {
                                              _showSnackBar(
                                                context,
                                                message: "terms.must_accept"
                                                    .tr(),
                                                background: Colors.orange,
                                                icon:
                                                    Icons.warning_amber_rounded,
                                              );
                                            },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _acceptedTerms
                                              ? colorScheme.primary
                                              : colorScheme.onSurface
                                                    .withOpacity(0.35),
                                          borderRadius: BorderRadius.circular(
                                            15.r,
                                          ),
                                        ),
                                        child: Text(
                                          "common.continue".tr(),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Manrope',
                                          ),
                                        ),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;

  const _CustomTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
  });

  @override
  State<_CustomTextFormField> createState() => __CustomTextFormFieldState();
}

class __CustomTextFormFieldState extends State<_CustomTextFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontSize: 14.sp,
          fontFamily: 'Manrope',
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

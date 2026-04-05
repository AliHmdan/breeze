import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  late final TermsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<TermsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.load());
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TermsCubit, TermsState>(
      bloc: cubit,
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColor.Dark,
            // appBar: PreferredSize(
            //   preferredSize: Size.fromHeight(60.h),
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 16.w),
            //     child: CustomAppbarProfile(icon: Icons.arrow_back_ios, ontap: () => Navigator.pop(context)),
            //   ),
            // ),
            body: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColor.primaryColor)),
              error: (msg) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    msg,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              loaded: (data) {
                final locale = context.locale.languageCode; // ar / en
                final text = data.byLocale(locale).replaceAll('\r\n', '\n').trim();

                return Padding(
                  padding: EdgeInsets.all(0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // SizedBox(height: 33.h),
                      // HeaderForProfileWidget(text: "profile.terms".tr()),
                      CustomAppbarProfile(title: "profile.terms".tr(), ontap: () => Navigator.pop(context), icon: Icons.arrow_back_ios),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          decoration: BoxDecoration(color: AppColor.Dark, borderRadius: BorderRadius.circular(12.r)),
                          child: SingleChildScrollView(
                            child: Text(
                              text.isEmpty ? "—" : text,
                              style: TextStyle(color: AppColor.white, fontSize: 14.sp, height: 1.65),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class HeaderForProfileWidget extends StatelessWidget {
  final String text;
  const HeaderForProfileWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 15.w, bottom: 12.w),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios, color: AppColor.white),
          ),
          SizedBox(width: 5.w),
          Text(text, style: TextStyle(color: AppColor.white)),
        ],
      ),
    );
  }
}

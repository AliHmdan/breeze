import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breezefood/features/auth/presentation/login_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showLogoutDialog(BuildContext context) {
  final cubit = getIt<AuthFlowCubit>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return BlocListener<AuthFlowCubit, AuthFlowState>(
        bloc: cubit,
        listener: (ctx, state) {
          state.whenOrNull(
            loading: () => EasyLoading.show(status: "logout.loading".tr()),

            error: (msg) {
              EasyLoading.dismiss();
            },
            loggedOut: (msg) {
              EasyLoading.dismiss();

              Navigator.pop(dialogCtx);

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Login()), (_) => false);
            },
          );
        },
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColor.Dark,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/icons/logout.svg",
                  width: 35.sp,
                  height: 35.sp,
                  colorFilter: ColorFilter.mode(AppColor.white, BlendMode.srcIn),
                ),
                const SizedBox(height: 12),
                CustomSubTitle(subtitle: "logout.confirm".tr(), color: AppColor.white, fontsize: 14.sp),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.h),
                        backgroundColor: AppColor.Dark,
                        foregroundColor: AppColor.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.r)),
                      ),
                      onPressed: () {
                        cubit.logout();
                      },
                      child: CustomSubTitle(subtitle: "common.yes".tr(), color: AppColor.white, fontsize: 14.sp),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.h),
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: AppColor.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.r)),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: CustomSubTitle(subtitle: "common.cancel".tr(), color: AppColor.white, fontsize: 14.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

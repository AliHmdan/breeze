import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsDialog extends StatefulWidget {
  const TermsDialog({super.key});

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  // 0 = AR, 1 = EN
  int _langIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: AppColor.Dark,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: BlocProvider(
        create: (_) => getIt<TermsCubit>()..load(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "terms.title".tr(),
                        style: TextStyle(color: AppColor.white, fontSize: 15.sp, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: Icon(Icons.close, color: AppColor.white.withOpacity(0.7)),
                      tooltip: "common.close".tr(),
                    ),
                  ],
                ),
              ),

              // Segmented language switch
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    // color: colorScheme.surfaceContainerHighest,
                    color: AppColor.search,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColor.white.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      _segButton(title: "AR", selected: _langIndex == 0, onTap: () => setState(() => _langIndex = 0)),
                      SizedBox(width: 8.w),
                      _segButton(title: "EN", selected: _langIndex == 1, onTap: () => setState(() => _langIndex = 1)),
                    ],
                  ),
                ),
              ),

              // SizedBox(height: 10.h),
              // Divider(color: AppColor.search.withOpacity(0.25), height: 1),

              // Body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: BlocBuilder<TermsCubit, TermsState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const SizedBox.shrink(),
                        loading: () => Center(
                          child: Text("common.loading".tr(), style: TextStyle(color: AppColor.primaryColor.withOpacity(0.7))),
                        ),
                        error: (msg) => Center(
                          child: Text(
                            msg,
                            style: TextStyle(color: colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        loaded: (data) {
                          final ar = data.ar.replaceAll('\r\n', '\n').trim();
                          final en = data.en.replaceAll('\r\n', '\n').trim();

                          final text = (_langIndex == 0) ? ar : en;

                          return Container(
                            padding: EdgeInsets.all(12.w),
                            width: 350.w,
                            decoration: BoxDecoration(
                              color: AppColor.search,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: AppColor.search.withOpacity(0.35)),
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Directionality(
                                  textDirection: _langIndex == 0 ? mt.TextDirection.rtl : mt.TextDirection.ltr,
                                  child: Text(
                                    text.isEmpty ? "—" : text,
                                    style: TextStyle(color: AppColor.white.withOpacity(0.88), fontSize: 13.sp, height: 1.65),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.white.withOpacity(0.7),
                          backgroundColor: AppColor.Dark,
                          side: BorderSide(color: AppColor.white.withOpacity(0.35)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("common.cancel".tr()),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("terms.i_agree".tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segButton({required String title, required bool selected, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: selected ? AppColor.primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(12.r)),
          child: Text(
            title,
            style: TextStyle(color: selected ? Colors.white : AppColor.white.withOpacity(0.7), fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

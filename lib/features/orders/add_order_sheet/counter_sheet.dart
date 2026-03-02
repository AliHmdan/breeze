import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterSheet extends StatelessWidget {
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;

  final double basePrice;
  final double extrasTotal;
  final ValueChanged<int> onAdd;
  final bool isRestaurantOpen;

  final bool isSizeRequired;
  final bool isSizeSelected;

  final VoidCallback? onMissingSize;

  const CounterSheet({
    super.key,
    required this.count,
    required this.onInc,
    required this.onDec,
    required this.onAdd,
    required this.basePrice,
    required this.extrasTotal,
    required this.isRestaurantOpen,
    required this.isSizeRequired,
    required this.isSizeSelected,
    this.onMissingSize,
  });

  double get total => (basePrice + extrasTotal) * count;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CartCubit>().state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final baseDisabled = isLoading || !isRestaurantOpen;
    // final sizeBlocked = isSizeRequired && !isSizeSelected;
    // final canAdd = !baseDisabled && !sizeBlocked;

    // final btnColor = canAdd ? AppColor.primaryColor : AppColor.red;
    final canAdd = !baseDisabled;
    // final btnText = sizeBlocked
    //     ? (context.locale.languageCode == "ar"
    //         ? "اختر الحجم (مطلوب)"
    //         : "Select size (required)")
    //     : "common.AddToCart".tr();
    final btnText = "common.AddToCart".tr();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // counter
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //   decoration: BoxDecoration(
              //     color: AppColor.black,
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Row(
              //     children: [
              //       Material(
              //         color: Colors.transparent,
              //         child: GestureDetector(
              //           onTap: (isLoading || count <= 1) ? null : onDec,
              //           child: const CircleAvatar(
              //             backgroundColor: Colors.white,
              //             radius: 16,
              //             child: Icon(Icons.remove, color: Colors.black),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 10),
              //       // ✅ ملاحظة: إذا CustomSubTitle عندك ما عم يتحدث، استبدله بـ Text مؤقتاً للتأكد
              //       CustomSubTitle(
              //         subtitle: "$count",
              //         color: AppColor.white,
              //         fontsize: 18,
              //       ),
              //       const SizedBox(width: 10),
              //       Material(
              //         color: Colors.transparent,
              //         child: GestureDetector(
              //           onTap: isLoading ? null : onInc,
              //           child: const CircleAvatar(
              //             backgroundColor: AppColor.primaryColor,
              //             radius: 16,
              //             child: Icon(Icons.add, color: Colors.white),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              //
              // const SizedBox(width: 8),

              // button
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          if (baseDisabled) return;

                          // if (sizeBlocked) {
                          //   onMissingSize?.call();
                          //   return;
                          // }

                          onAdd(count);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  transitionBuilder: (c, a) =>
                                      FadeTransition(opacity: a, child: c),
                                  child: Text(
                                    btnText,
                                    key: ValueKey(btnText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),

                              Text(
                                context.syp(total),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (!isRestaurantOpen) ...[
            SizedBox(height: 8.h),
            Text(
              "restaurant.closed_cannot_add_to_cart".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

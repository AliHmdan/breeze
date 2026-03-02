import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order_sheet/Counter.dart';
// import 'package:breezefood/features/orders/add_order_sheet/Counter.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_description.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddOrderTitlePrice extends StatelessWidget {
  final String title;
  final double price;
  final double oldPrice;
  final bool hasDiscount;

  final String description;
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const AddOrderTitlePrice({
    super.key,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.hasDiscount,
    required this.description,
    required this.count,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CartCubit>().state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),

        /// TITLE
        Text(
          title.isEmpty ? "Empty" : title,

          style: TextStyle(
            color: AppColor.white,
            fontSize: 22.sp,
            fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                ? 'Cairo'
                : 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),

        /// DESCRIPTION
        AddOrderDescription(description: description, maxWidth: 300.w),

        SizedBox(height: 12.h),

        /// PRICE + COUNTER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// PRICE SECTION
            Row(
              children: [
                if (hasDiscount) ...[
                  Text(
                    context.syp(oldPrice),
                    style: TextStyle(
                      color: AppColor.gry,
                      fontSize: 14.sp,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColor.gry,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],

                Text(
                  context.syp(price),
                  style: TextStyle(
                    color: hasDiscount ? AppColor.red : AppColor.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // / COUNTER
            CounterWidget(
              count: count,
              isLoading: isLoading,
              onInc: onInc,
              onDec: onDec,
            ),
          ],
        ),
      ],
    );
  }
}

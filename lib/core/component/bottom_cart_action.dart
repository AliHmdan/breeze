import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/cart_summary_model.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/core/component/have_order.dart';
import 'package:breezefood/core/services/money.dart';

import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/core/component/color.dart';

class BottomCartAction extends StatelessWidget {
  final VoidCallback onViewCart;
  final OrderInfo? haveOrder;

  final bool usePrimaryButton;
  final bool showCountAndTotal;

  const BottomCartAction({
    super.key,
    required this.onViewCart,
    required this.haveOrder,
    this.usePrimaryButton = true,
    this.showCountAndTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, st) {
        bool loading = false;
        CartSummary summary = CartSummary.empty;

        st.maybeWhen(
          loading: () => loading = true,
          cartLoaded: (cart, updatingIds, toast, isRefreshing) {
            summary = CartSummary.from(cart);
          },
          orElse: () {},
        );

        if (loading) {
          return const SizedBox.shrink();
        }

        if (summary.hasCart) {
          final title = showCountAndTotal
              ? "${'cart.view_cart'.tr()} • ${summary.count} • ${context.money(summary.total, decimals: 0)}"
              : "cart.view_cart".tr();

          return SafeArea(
            top: false,
            child: Container(
             
              padding: EdgeInsets.fromLTRB(
                14.w, // ✅ Removed horizontal padding for full width
                10.h,
                14.w, // ✅ Removed horizontal padding for full width
                12.h,
              ),
              decoration: BoxDecoration(
                color: AppColor.Dark.withOpacity(0.92),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                    width: 1,
                  ),
                ),
              ),
              child: usePrimaryButton
                  ? CustomButton(title: title, onPressed: onViewCart)
                  : CustomButtonOrder(title: title, onPressed: onViewCart),
            ),
          );
        }

        // ✅ ما في سلة -> Your Order
        if (haveOrder != null) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                0.w,
                10.h,
                0.w,
                12.h,
              ), // ✅ Removed horizontal padding for full width
              child: CustomButtonOrder(
                title: "home.your_order".tr(),
                onPressed: () => openHaveOrderTracking(context, haveOrder!.id),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

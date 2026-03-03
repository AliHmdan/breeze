import 'package:breezefood/core/component/bottom_cart_action.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/features/profile/presentation/cubit/addresses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';

class CartActionButton extends StatelessWidget {
  final VoidCallback onViewCart;
  final OrderInfo? haveOrder;

  const CartActionButton({
    super.key,
    required this.onViewCart,
    required this.haveOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BottomCartAction(
      haveOrder: haveOrder,
      usePrimaryButton: false, // ✅ لأنه بدك CustomButtonOrder
      showCountAndTotal: false, // ✅ بس "View Cart" بدون أرقام (متل الكود تبعك)
      onViewCart: onViewCart,
    );
  }
}

class SupermarketBottomButton extends StatelessWidget {
  const SupermarketBottomButton({super.key, this.onAfterBack, this.haveOrder});

  final VoidCallback? onAfterBack;
  final OrderInfo? haveOrder; // ✅ خليه optional إذا بدك تعرض Track Order

  @override
  Widget build(BuildContext context) {
    return BottomCartAction(
      haveOrder: haveOrder,
      usePrimaryButton: true, // ✅ لأنه بدك CustomButton (الزر الكبير)
      showCountAndTotal: true, // ✅ لأنه بدك count + total
      onViewCart: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                   BlocProvider.value(value: context.read<CartCubit>()),
                        BlocProvider(create: (_) => getIt<OrderFlowCubit>()),
                        BlocProvider(create: (_) => getIt<AddressesCubit>()),
              ],
              child: const RequestOrderScreen(),
            ),
          ),
        );

        if (context.mounted) {
          context.read<CartCubit>().loadCart();
          onAfterBack?.call();
        }
      },
    );
  }
}

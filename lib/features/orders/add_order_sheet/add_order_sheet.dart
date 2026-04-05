import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_order_body.dart';

Future<void> showAddOrderDialog(
  BuildContext context, {
  required int restaurantId,
  required int menuItemId,
  required String title,
  required double price,
  required double oldPrice,
  required String imagePathOrUrl,
  required String description,
  required List<MenuExtra> extraMeals,
  required List<ExtraGrouped> extraGroups,
  required bool isRestaurantOpen,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // enableDrag: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (sheetCtx) {
      final height = MediaQuery.of(sheetCtx).size.height * 0.9;

      // ✅ خذ CartCubit من سياق الصفحة (context) مو sheetCtx
      final cartCubit = context.read<CartCubit>();

      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) {
          return MediaQuery.removePadding(
            context: sheetCtx,
            removeTop: true,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 600),
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: AppColor.Dark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: BlocProvider.value(
                  value: cartCubit,
                  child: AddOrderBody(
                    restaurantId: restaurantId,
                    menuItemId: menuItemId,
                    scrollController: scrollController,
                    title: title,
                    price: price,
                    oldPrice: oldPrice,
                    imagePathOrUrl: imagePathOrUrl,
                    description: description,
                    extras: extraMeals,
                    extraGroups: extraGroups,
                    isRestaurantOpen: isRestaurantOpen,
                  ),
                ),
              ),
            ),
          );
        },
      );
      ;
    },
  );
}

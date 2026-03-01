import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'; // OrderBundle
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';

class OrdersHistory extends StatefulWidget {
  const OrdersHistory({super.key});

  @override
  State<OrdersHistory> createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {
  Future<void> _refresh() async {
    await context.read<OrdersCubit>().loadHistory();
  }

  String _fullUrl(String path) {
    final p = (path).trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;

    // السيرفر يرجّع أحياناً بدون "/" أو مع "//"
    final fixed = p.startsWith("/") ? p.substring(1) : p;
    return "https://breezefood.cloud/$fixed"
        .replaceAll("//", "/")
        .replaceFirst("https:/", "https://");
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains("delivered") || s.contains("completed")) return Colors.green;
    if (s.contains("cancel")) return Theme.of(context).colorScheme.error;
    if (s.contains("pending")) return Colors.orange;
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
  }

  Future<void> _onReorderPressed(OrderBundle bundle) async {
    final cartCubit = context.read<CartCubit>();

    // 1️⃣ أضف الطلب للسلة
    await cartCubit.reorderFromHistory(bundle);

    if (!mounted) return;

    // 2️⃣ انتقل لصفحة تفاصيل المطعم
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResturantDetails(restaurant_id: bundle.restaurant.id),
      ),
    );
  }

  Widget _buildOrderCard(OrderBundle bundle) {
    final colorScheme = Theme.of(context).colorScheme;
    final item = bundle.order;
    final restaurant = bundle.restaurant;

    final createdAt = DateTime.parse(item.createdAt);
    final date = DateFormat("dd MMM, yyyy • hh:mm a").format(createdAt);

    return Container(
      // color: Color(0xffF2F2F2), // ✅ خلفية فاتحة
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              /// صورة المطعم
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _fullUrl(restaurant.logo),
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    "assets/images/003.jpg",
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (item.isVip)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 14.sp,
                                  color: colorScheme.onPrimary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "orders.vip_badge".tr(),
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// السعر
                    Text(
                      "${item.totalPrice.toStringAsFixed(2)} ${"common.currency".tr()}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),
                  ],
                ),
              ),

              /// زر إعادة الطلب
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  color: colorScheme.onSurface,
                  onPressed: () => _onReorderPressed(bundle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          /// التاريخ + الحالة
          ///
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              children: [
                TextSpan(text: "$date • "),
                TextSpan(
                  text: "Delivered",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Text(
          //   "$date • Delivered",
          //   style: TextStyle(
          //     fontSize: 12.sp,
          //     color: Colors.grey[600], // ✅ رمادي خفيف
          //   ),
          // ),
          const SizedBox(height: 14),

          /// Divider خفيف جداً
          Divider(
            color: colorScheme.outline.withOpacity(0.25),
            thickness: 1,
            height: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final orders = state.maybeWhen(
          historyLoaded: (o) => o,
          orElse: () => cubit.historyCache,
        );

        final isLoading = state.maybeWhen(
          loadingHistory: () => true,
          orElse: () => false,
        );

        final errorMsg = state.maybeWhen(
          errorHistory: (m) => m,
          orElse: () => null,
        );

        if (isLoading && orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMsg != null && orders.isEmpty) {
          return Center(
            child: Text(
              errorMsg,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (orders.isEmpty) {
          return Center(
            child: Text(
              "orders.empty_history".tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              for (final order in orders) _buildOrderCard(order),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/order_traking_map.dart';
import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'; // OrderBundle
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_tracking_state.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrentOrders extends StatefulWidget {
  const CurrentOrders({super.key});

  @override
  State<CurrentOrders> createState() => _CurrentOrdersState();
}

class _CurrentOrdersState extends State<CurrentOrders> {
  Future<void> _refresh() async {
    await context.read<OrdersCubit>().loadActive();
  }

  String _statusKey(String status) {
    final s = status.toLowerCase();
    if (s.contains("pending")) return "orders.status_pending";
    if (s.contains("preparing")) return "orders.status_preparing";
    if (s.contains("delivered") || s.contains("completed")) {
      return "orders.status_delivered";
    }
    if (s.contains("cancel")) return "orders.status_cancelled";
    return "orders.status_unknown";
  }

  String _fullUrl(String path) {
    final p = path.trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;

    final fixed = p.startsWith("/") ? p.substring(1) : p;
    return "https://breezefood.cloud/$fixed"
        .replaceAll("//", "/")
        .replaceFirst("https:/", "https://");
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains("pending")) return Colors.orange;
    if (s.contains("preparing")) return Colors.cyan;
    if (s.contains("delivered") || s.contains("completed")) return Colors.green;
    if (s.contains("cancel")) return Theme.of(context).colorScheme.error;
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
  }

  Widget _buildOrderCard(OrderBundle bundle) {
    final colorScheme = Theme.of(context).colorScheme;
    final item = bundle.order;
    final restaurant = bundle.restaurant;

    final statusColor = _statusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) =>
                          OrdersTrackingCubit(getIt<OrdersRepository>())
                            ..start(item.id),
                    ),
                    BlocProvider(
                      create: (_) =>
                          OrdersDetailsCubit(getIt<OrdersRepository>())
                            ..load(item.id), // ✅ نادِ myOrderDetails هون
                    ),
                  ],
                  child: OrderTrackingScreen(orderId: item.id),
                ),
              ),
            );
          },

          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 10, top: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      _fullUrl(restaurant.logo),
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/003.jpg",
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomSubTitle(
                              subtitle: restaurant.name,
                              color: colorScheme.onSurface,
                              fontsize: 14.sp,
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
                      CustomSubTitle(
                        subtitle: _statusKey(item.status).tr(),
                        color: statusColor,
                        fontsize: 12.sp,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "orders.price_label".tr(),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontFamily: "Manrope",
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${item.totalPrice.toStringAsFixed(0)} ${"common.currency".tr()}",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      CustomSubTitle(
                        subtitle: "orders.items_count".tr(
                          namedArgs: {"count": item.itemsCount.toString()},
                        ),
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontsize: 11.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final orders = state.maybeWhen(
          activeLoaded: (o) => o,
          orElse: () => cubit.activeCache,
        );

        final isLoading = state.maybeWhen(
          loadingActive: () => true,
          orElse: () => false,
        );

        final errorMsg = state.maybeWhen(
          errorActive: (m) => m,
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
              "orders.no_current_orders".tr(),
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

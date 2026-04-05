import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/features/orders/model/orders_history_response.dart';

part 'orders_state.dart';
part 'orders_cubit.freezed.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repo;
  OrdersCubit(this.repo) : super(const OrdersState.initial());

  List<OrderBundle> _activeCache = const [];
  List<OrderBundle> _historyCache = const [];

  List<OrderBundle> get activeCache => _activeCache;
  List<OrderBundle> get historyCache => _historyCache;

  Future<void> loadActive() async {
    emit(const OrdersState.loadingActive());
    print('/////////////////////////');
    print('/////////////////////////');
    print('loadActive');
    print('/////////////////////////');
    print('/////////////////////////');

    final res = await repo.getActiveOrders();
    if (!res.ok) {
      emit(OrdersState.errorActive(res.message ?? "خطأ"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    final parsed = ActiveOrdersResponse.fromJson(map);

    _activeCache = parsed.orders;
    emit(OrdersState.activeLoaded(_activeCache));
  }

  Future<void> loadHistory() async {
    emit(const OrdersState.loadingHistory());

    print('/////////////////////////');
    print('/////////////////////////');
    print('loadHistory');
    print('/////////////////////////');
    print('/////////////////////////');

    final res = await repo.getOrdersHistory();
    if (!res.ok) {
      emit(OrdersState.errorHistory(res.message ?? "خطأ"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    final parsed = ActiveOrdersResponse.fromJson(map);

    _historyCache = parsed.orders;
    emit(OrdersState.historyLoaded(_historyCache));
  }

  Future<int?> fetchOrderCustomerCode(int orderId) async {
    final res = await repo.getMyOrderDetails(orderId);
    if (!res.ok) return null;
    print('/////////////////////////');
    print('/////////////////////////');
    print('fetchOrderCustomerCode');
    print('/////////////////////////');
    print('/////////////////////////');

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};

    final bundle = OrderBundle.fromJson(map);
    return bundle.order.orderCustomerCode;
  }
}

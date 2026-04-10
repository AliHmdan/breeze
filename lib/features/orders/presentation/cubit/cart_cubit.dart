import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/data/repo/cart_repository.dart';
import 'package:breezefood/features/orders/model/cart_response.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';

part 'cart_state.dart';
part 'cart_cubit.freezed.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repo;
  CartCubit(this.repo) : super(const CartState.initial());

  bool _loadingInFlight = false;
  bool _addInFlight = false;

  void _safeEmit(CartState s) {
    if (!isClosed) emit(s);
  }

  _CartLoaded? _loaded() => state is _CartLoaded ? state as _CartLoaded : null;
  bool get _hasLoaded => state.maybeWhen(
    cartLoaded: (cart, updatingIds, toast, isRefreshing) => true,
    orElse: () => false,
  );

  // ===========================================================
  // ✅ LOAD CART (supports silent refresh)
  // ===========================================================
  Future<void> loadCart({bool silent = false}) async {
    if (isClosed || _loadingInFlight) return;
    _loadingInFlight = true;

    final prev = _loaded();
    final alreadyLoaded = prev != null;

    if (!alreadyLoaded) {
      _safeEmit(const CartState.loading());
    } else if (silent) {
      _safeEmit(prev.copyWith(toast: null));
    }

    try {
      final res = await repo.getCart();
      if (!res.ok) {
        _safeEmit(CartState.error(res.message ?? "فشل تحميل السلة"));
        return;
      }

      final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
      final cart = CartResponse.fromJson(map);

      _safeEmit(
        CartState.cartLoaded(
          cart: cart,
          updatingIds: prev?.updatingIds ?? {},
          toast: null,
          isRefreshing: false,
        ),
      );
    } catch (e, s) {
      log("loadCart ❌ $e\n$s");
      _safeEmit(const CartState.error("تعذر تحميل السلة"));
    } finally {
      _loadingInFlight = false;
    }
  }

  // ===========================================================
  // ✅ ADD TO CART (Optimistic + silent reload)
  // ===========================================================
  Future<void> add(AddToCartRequest req) async {
    log("CartCubit.add ✅ isClosed=$isClosed req=$req");
    if (isClosed) return;
    if (_addInFlight) return;

    _addInFlight = true;

    final stPrev = _loaded();
    final alreadyLoaded = stPrev != null;
    final menuId = req.menuItemId;

    // ✅ لو عندي سلة: بس علّم الـ item عم يتحدّث (ما نخرب الـ UI)
    if (alreadyLoaded) {
      emit(
        stPrev.copyWith(
          updatingIds: {...stPrev.updatingIds, menuId},
          toast: null,
        ),
      );
    } else {
      // ✅ لو ما في بيانات: خلي الزر يبين loading
      emit(const CartState.addingToCart());
    }

    try {
      final res = await repo.addToCart(req);
      if (isClosed) return;

      if (!res.ok) {
        final msg = res.message ?? "فشل إضافة المنتج للسلة";

        final stNow = _loaded();
        if (stNow != null) {
          emit(
            stNow.copyWith(
              updatingIds: {...stNow.updatingIds}..remove(menuId),
              toast: msg,
            ),
          );
        } else {
          emit(CartState.error(msg));
        }
        return;
      }

      final data = (res.data as Map?)?.cast<String, dynamic>() ?? {};
      final msg = (data["message"]?.toString().trim().isNotEmpty ?? false)
          ? data["message"].toString()
          : "Added to cart";

      // ✅ Toast خفيف
      final stNow = _loaded();
      if (stNow != null) {
        emit(stNow.copyWith(toast: msg));
      } else {
        emit(CartState.addedSuccess(message: msg));
      }

      // ✅ حدّث السلة فوراً
      await loadCart(silent: true);
    } catch (e, s) {
      log("CartCubit.add ❌ $e\n$s");
      final stNow = _loaded();

      if (stNow != null) {
        emit(
          stNow.copyWith(
            updatingIds: {...stNow.updatingIds}..remove(menuId),
            toast: "تعذر إضافة المنتج",
          ),
        );
      } else {
        emit(const CartState.error("تعذر إضافة المنتج"));
      }
    } finally {
      _addInFlight = false;

      // ✅ تأكد نزيل الـ updatingId حتى لو صار Exception
      final stNow = _loaded();
      if (stNow != null && stNow.updatingIds.contains(menuId)) {
        emit(
          stNow.copyWith(updatingIds: {...stNow.updatingIds}..remove(menuId)),
        );
      }
    }
  }

  // ===========================================================
  // ✅ REORDER FROM HISTORY (Production Safe)
  // ===========================================================
  Future<void> reorderFromHistory(OrderBundle bundle) async {
    if (isClosed) return;

    if (!_hasLoaded) {
      await loadCart();
    }

    final restaurantId = bundle.restaurant.id;
    final failed = <String>[];

    for (final item in bundle.items) {
      final req = AddToCartRequest(
        restaurantId: restaurantId,
        menuItemId: item.menuItemId,
        quantity: item.quantity,
        specialNotes: "",
        withSpicy: item.withSpicy,
        extras: const [],
      );

      await add(req);

      final isError = state.maybeWhen(error: (_) => true, orElse: () => false);

      if (isError) failed.add(item.title);
    }

    await loadCart(silent: true);

    if (failed.isNotEmpty) {
      final st = _loaded();
      if (st != null) {
        _safeEmit(
          st.copyWith(
            toast:
                "تعذر إضافة: ${failed.take(3).join(", ")}${failed.length > 3 ? "..." : ""}",
          ),
        );
      }
    }
  }

  // ===========================================================
  // UPDATE QTY (Optimistic)
  // ===========================================================
  Future<void> updateQty({
    required int cartItemId,
    required int quantity,
  }) async {
    final st = _loaded();
    if (st == null || quantity < 1) return;

    final prevCart = st.cart;
    final idx = prevCart.items.indexWhere((e) => e.id == cartItemId);
    if (idx == -1) return;

    final oldItem = prevCart.items[idx];

    final optimisticItem = oldItem.copyWith(
      quantity: quantity,
      totalPrice: (oldItem.unitPrice * quantity) + oldItem.extrasTotal,
    );

    final newItems = [...prevCart.items];
    newItems[idx] = optimisticItem;

    _safeEmit(
      st.copyWith(
        cart: prevCart.copyWith(items: newItems),
        updatingIds: {...st.updatingIds, cartItemId},
      ),
    );

    final res = await repo.updateQty(
      cartItemId: cartItemId,
      quantity: quantity,
    );

    if (!res.ok) {
      await loadCart(silent: true);
      return;
    }

    await loadCart(silent: true);

    // Remove the updatingId after successful update
    final stNow = _loaded();
    if (stNow != null && stNow.updatingIds.contains(cartItemId)) {
      _safeEmit(
        stNow.copyWith(updatingIds: {...stNow.updatingIds}..remove(cartItemId)),
      );
    }
  }

  // ===========================================================
  // REMOVE ITEM (Optimistic)
  // ===========================================================
  Future<void> removeItem(int cartItemId) async {
    final st = _loaded();
    if (st == null) return;

    final prevCart = st.cart;
    final newItems = prevCart.items.where((e) => e.id != cartItemId).toList();

    _safeEmit(
      st.copyWith(
        cart: prevCart.copyWith(items: newItems),
        updatingIds: {...st.updatingIds, cartItemId},
      ),
    );

    final res = await repo.removeItem(cartItemId: cartItemId);
    if (!res.ok) {
      await loadCart(silent: true);
      return;
    }

    await loadCart(silent: true);

    // Remove the updatingId after successful removal
    final stNow = _loaded();
    if (stNow != null && stNow.updatingIds.contains(cartItemId)) {
      _safeEmit(
        stNow.copyWith(updatingIds: {...stNow.updatingIds}..remove(cartItemId)),
      );
    }
  }

  // ===========================================================
  // CLEAR ALL CART
  // ===========================================================
  Future<void> clearCart() async {
    // Show loading state
    _safeEmit(const CartState.loading());

    try {
      final st = _loaded();
      if (st != null && st.cart.items.isNotEmpty) {
        log("Removing all items from cart one by one...");

        // Remove all items one by one using existing API
        for (final item in st.cart.items) {
          try {
            await repo.removeItem(cartItemId: item.id);
            log("Removed item ${item.id} successfully");
          } catch (e) {
            log("Failed to remove item ${item.id}: $e");
          }
        }
      }

      log("All items removed, clearing cart locally");
      // Clear cart locally
      _clearCartLocally();
    } catch (e, s) {
      log("clearCart exception: $e\n$s, falling back to local clear only");
      // Fallback: clear cart locally even if exception occurs
      _clearCartLocally();
    }
  }

  void _clearCartLocally() {
    // Create empty cart response
    final emptyCart = CartResponse(
      primaryAddress: null,
      addresses: [],
      orderId: 0,
      orderStatus: "",
      restaurantId: 0,
      restaurantName: "",
      restaurantLogo: "",
      items: [],
      appetizers: [],
      itemsTotalBefore: 0,
      itemsTotalAfter: 0,
      itemsDiscount: 0,
      appetizersTotal: 0,
      deliveryBefore: 0,
      deliveryAfter: 0,
      deliveryDiscount: 0,
      grandBefore: 0,
      grandAfter: 0,
      vip: null,
    );

    // Emit empty cart state
    _safeEmit(
      CartState.cartLoaded(
        cart: emptyCart,
        updatingIds: {},
        toast: null,
        isRefreshing: false,
      ),
    );

    log("Cart cleared locally successfully");
  }
}

import 'package:breezefood/features/orders/data/api/cart_api_service.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart'
    show AppResponseHandler;

class CartRepository {
  final CartApiService api;
  CartRepository(this.api);

  Future<AppResponse> addToCart(AddToCartRequest req) async {
    try {
      final res = await api.addToCart(req.toJson());
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل الاتصال");
    }
  }

  Future<AppResponse> getCart() async {
    try {
      final res = await api.getCart();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل السلة");
    }
  }

  Future<AppResponse> updateQty({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final res = await api.updateQty(cartItemId, {"quantity": quantity});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحديث الكمية");
    }
  }

  // ✅ NEW
  Future<AppResponse> removeItem({required int cartItemId}) async {
    try {
      final res = await api.removeItem(cartItemId);
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل حذف العنصر");
    }
  }

  // NEW: clear all cart
  Future<AppResponse> clearCart() async {
    try {
      final res = await api.clearCart();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل حذف السلة");
    }
  }
}

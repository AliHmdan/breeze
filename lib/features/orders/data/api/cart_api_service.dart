import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'cart_api_service.g.dart';

@RestApi()
abstract class CartApiService {
  factory CartApiService(Dio dio, {String? baseUrl}) = _CartApiService;

  @POST("/cart/add")
  Future<HttpResponse<dynamic>> addToCart(@Body() Map<String, dynamic> body);

  @GET("/cart/my-cart")
  Future<HttpResponse<dynamic>> getCart();

  @POST("/cart/item/{id}/update-qty")
  Future<HttpResponse<dynamic>> updateQty(
    @Path("id") int itemId,
    @Body() Map<String, dynamic> body,
  );

  // ✅ NEW: remove item
  @GET("/cart/item/{id}/remove-item")
  Future<HttpResponse<dynamic>> removeItem(@Path("id") int itemId);

  // NEW: clear all cart
  @DELETE("/cart/clear")
  Future<HttpResponse<dynamic>> clearCart();
}

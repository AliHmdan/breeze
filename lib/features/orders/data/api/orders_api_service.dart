import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'orders_api_service.g.dart';

@RestApi()
abstract class OrdersApiService {
  factory OrdersApiService(Dio dio, {String? baseUrl}) = _OrdersApiService;

  @POST("/orders/store")
  Future<HttpResponse<dynamic>> storeOrder(
    @Body() Map<String, dynamic> body,
  );

  @POST("/activeOrders")
  Future<HttpResponse<dynamic>> activeOrders();

  @POST("/ordersHistory")
  Future<HttpResponse<dynamic>> ordersHistory();

  @POST("/my-order-details")
  Future<HttpResponse<dynamic>> myOrderDetails(
    @Body() Map<String, dynamic> body,  
  );
  @POST("/orders/{id}/driver-location")
Future<HttpResponse<dynamic>> driverLocation(
  @Path("id") int orderId,
);
@DELETE("/orders/{id}")
Future<HttpResponse<dynamic>> cancelOrder(
  @Path("id") int orderId,
);

}

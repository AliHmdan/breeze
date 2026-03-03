import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'addresses_api_service.g.dart';

@RestApi()
abstract class AddressesApiService {
  factory AddressesApiService(Dio dio, {String? baseUrl}) = _AddressesApiService;

  @GET("/profile/my-address")
  Future<HttpResponse<dynamic>> getMyAddresses();

  @POST("/profile/addresses")
  Future<HttpResponse<dynamic>> addAddress(@Body() Map<String, dynamic> body);

  @DELETE("/profile/addresses")
  Future<HttpResponse<dynamic>> deleteAddress(@Body() Map<String, dynamic> body);
}
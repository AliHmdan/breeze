import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;
import '../api/addresses_api_service.dart';

class AddressesRepository {
  final AddressesApiService api;
  AddressesRepository(this.api);

  Future<AppResponse> getMyAddresses( ) async {
    try {
      final res = await api.getMyAddresses( );
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل العناوين");
    }
  }

  Future<AppResponse> addAddress({
    required String label,
    required String address,
    required double lat,
    required double lon,
    required bool isDefault,
  }) async {
    try {
      final res = await api.addAddress({
        "label": label,
        "address": address,
        "latitude": lat,
        "longitude": lon,
        "is_default": isDefault,
      });
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إضافة العنوان");
    }
  }

  Future<AppResponse> deleteAddress(int id) async {
    try {
      final res = await api.deleteAddress({"id": id});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل حذف العنوان");
    }
  }
}
import 'package:breezefood/core/network/api_result.dart';
import 'package:dio/dio.dart';

class AppetizersRepository {
  final Dio dio;
  AppetizersRepository(this.dio);

  Future<AppResponse> getAppetizers(int restaurantId) async {
    try {
      final res = await dio.get("/appetizers/$restaurantId");
      return AppResponseHandler.handle(res);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل المقبلات");
    }
  }

  Future<AppResponse> syncAppetizers({
    required List<Map<String, dynamic>> appetizers,
  }) async {
    try {
      final res = await dio.post(
        "/sync-appetizers",
        data: {"appetizers": appetizers},
      );
      return AppResponseHandler.handle(res);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحديث المقبلات");
    }
  }
}

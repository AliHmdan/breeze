import 'package:breezefood/core/network/api_result.dart';
import 'package:dio/dio.dart';

class AssistantRepository {
  final Dio dio;
  AssistantRepository(this.dio);

  Future<AppResponse> start() async {
    try {
      final res = await dio.post("/assistant/start");
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل بدء المساعد");
    }
  }

  Future<AppResponse> chat({required String message}) async {
    try {
      final res = await dio.post(
        "/assistant/chat",
        data: {"message": message},
      );
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إرسال الرسالة");
    }
  }
}

import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart'
    show AppResponseHandler;
import 'package:breezefood/features/profile/data/api/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService profileApi;

  ProfileRepository(this.profileApi);

  Future<AppResponse> me() async {
    try {
      final res = await profileApi.me();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل بيانات الحساب");
    }
  }

  Future<AppResponse> updateProfile({
    String? firstName,
    String? lastName,
    String? profileImagePath,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (firstName != null) body["first_name"] = firstName;
      if (lastName != null) body["last_name"] = lastName;
      if (profileImagePath != null) body["profile_image"] = profileImagePath;

      final res = await profileApi.updateProfile(body);
      return AppResponse.ok(data: res.data);
    } catch (e) {
      return AppResponse.fail(message: e.toString());
    }
  }

  Future<AppResponse> getAvatars() async {
    try {
      final res = await profileApi.avatars();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل الأفاتارات");
    }
  }
}

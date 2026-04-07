import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/auth/data/repo/auth_repository.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart';

part 'auth_flow_state.dart';
part 'auth_flow_cubit.freezed.dart';

class AuthFlowCubit extends Cubit<AuthFlowState> {
  final AuthRepository repo;
  AuthFlowCubit(this.repo) : super(const AuthFlowState.initial());

  Future<void> logout() async {
    emit(const AuthFlowState.loading());

    final res = await repo.logout();
    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "فشل تسجيل الخروج"));
      return;
    }

    emit(AuthFlowState.loggedOut(res.message ?? "Logged out successfully"));
  }

  // ✅ عدّل هون
  Future<void> sendCode({
    required String phone,
    String referralCode = "",
  }) async {
    emit(const AuthFlowState.loading());

    final res = await repo.login(phone: phone, referralCode: referralCode);

    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "خطأ"));
      return;
    }

    emit(AuthFlowState.codeSent(res.data));
  }
  Future<void> verify({
    required String phone,
    required String code,
    String? deviceToken,
  }) async {
    emit(const AuthFlowState.loading());

    String? fcm = deviceToken;

    try {
      if (fcm == null || fcm.trim().isEmpty) {
        fcm = await FirebaseMessaging.instance.getToken();
      }
    } catch (_) {}

    print("📲 FCM token to send: ${fcm?.substring(0, 25)}...");

    final res = await repo.verifyPhone(
      phone: phone,
      code: code,
      firebaseToken: fcm,
    );

    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "خطأ"));
      return;
    }

    await AuthStorageHelper.clearGuestMode();

    // 🔥 check بيانات المستخدم
    final user = res.data['user'];

    final firstName = user['first_name'];
    final lastName = user['last_name'];

    bool isEmpty(String? v) => v == null || v.toString().trim().isEmpty;

    if (isEmpty(firstName) || isEmpty(lastName)) {
      emit(AuthFlowState.needProfileCompletion(res.data));
    } else {
      emit(AuthFlowState.authenticated(res.data));
    }
  }
  // Future<void> verify({
  //   required String phone,
  //   required String code,
  //   String? deviceToken,
  // }) async {
  //   emit(const AuthFlowState.loading());
  //
  //   String? fcm = deviceToken;
  //
  //   try {
  //     if (fcm == null || fcm.trim().isEmpty) {
  //       fcm = await FirebaseMessaging.instance.getToken();
  //     }
  //   } catch (_) {}
  //
  //   print("📲 FCM token to send: ${fcm?.substring(0, 25)}...");
  //
  //   final res = await repo.verifyPhone(
  //     phone: phone,
  //     code: code,
  //     firebaseToken: fcm,
  //   );
  //
  //   if (!res.ok) {
  //     emit(AuthFlowState.error(res.message ?? "خطأ"));
  //     return;
  //   }
  //
  //   await AuthStorageHelper.clearGuestMode();
  //   emit(AuthFlowState.verified(res.data));
  // }

  Future<void> resend({required String phone}) async {
    emit(const AuthFlowState.loading());

    final res = await repo.resendCode(phone: phone);
    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "خطأ"));
      return;
    }

    emit(AuthFlowState.codeResent(res.data));
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    emit(const AuthFlowState.loading());

    final res = await repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
    );
    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "خطأ"));
      return;
    }

    emit(AuthFlowState.profileUpdated(res.data));
  }

  Future<void> addAddress({
    required String address,
    required double lat,
    required double lon,
  }) async {
    emit(const AuthFlowState.loading());

    final res = await repo.addAddress(
      address: address,
      latitude: lat,
      longitude: lon,
    );

    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "خطأ"));
      return;
    }

    emit(AuthFlowState.addressAdded(res.data));
  }
}

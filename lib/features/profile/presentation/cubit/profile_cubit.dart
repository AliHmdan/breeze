import 'package:breezefood/features/profile/data/model/address_model.dart';
import 'package:breezefood/features/profile/data/model/avatar_model.dart';
import 'package:breezefood/features/profile/data/model/user_model.dart';
import 'package:breezefood/features/profile/data/repo/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repo;
  ProfileCubit(this.repo) : super(const ProfileState.initial());

  // =========================
  // Load Me
  // =========================
  Future<void> load() async {
    // ✅ حافظ على القيم من الحالة السابقة (avatars + selectedAvatarPath)
    final prev = state;
    final prevLoaded = prev is _Loaded ? prev : null;

    emit(const ProfileState.loading());

    final meRes = await repo.me();
    if (!meRes.ok) {
      emit(ProfileState.error(meRes.message ?? "خطأ"));
      if (prevLoaded != null) emit(prevLoaded);
      return;
    }

    try {
      final raw = meRes.data;
      if (raw is! Map) {
        emit(const ProfileState.error("فشل قراءة بيانات الحساب"));
        if (prevLoaded != null) emit(prevLoaded);
        return;
      }

      final root = raw.cast<String, dynamic>();

      final dynamic inner = root["data"];
      final Map<String, dynamic> data = (inner is Map)
          ? inner.cast<String, dynamic>()
          : root;

      final user = UserModel.fromJson(data);

      // ✅ addresses
      final List<AddressModel> addresses = [];
      final rawAddresses = data["addresses"];
      if (rawAddresses is List) {
        for (final e in rawAddresses) {
          if (e is Map) {
            addresses.add(AddressModel.fromJson(e.cast<String, dynamic>()));
          }
        }
      }

      emit(
        ProfileState.loaded(
          user: user,
          addresses: addresses,
          avatars: prevLoaded?.avatars ?? const <AvatarModel>[],
          selectedAvatarPath: prevLoaded?.selectedAvatarPath,
          isSaving: false,
          message: null,
        ),
      );
    } catch (_) {
      emit(const ProfileState.error("فشل قراءة بيانات الحساب"));
      if (prevLoaded != null) emit(prevLoaded);
    }
  }

  // =========================
  // Avatars
  // =========================
  Future<void> loadAvatars() async {
    final current = state;
    if (current is! _Loaded) return;

    final res = await repo.getAvatars();
    if (!res.ok) return;

    try {
      final raw = res.data;
      if (raw is! Map) return;

      final parsed = AvatarsResponse.fromJson(raw.cast<String, dynamic>());
      emit(current.copyWith(avatars: parsed.data));
    } catch (_) {}
  }

  /// ✅ اختيار avatar (نخزن path مباشرة)
  void selectAvatarPath(String path) {
    final current = state;
    if (current is! _Loaded) return;

    emit(current.copyWith(selectedAvatarPath: path));
  }

  /// ✅ خيار مساعد: مرّر AvatarModel مباشرة
  void selectAvatar(AvatarModel avatar) => selectAvatarPath(avatar.path);

  // =========================
  // Save Profile (JSON: first_name + last_name + profile_image(path))
  // =========================
  Future<void> saveProfile({String? firstName, String? lastName}) async {
    final current = state;
    if (current is! _Loaded) return;

    // ✅ لازم first/last موجودين دائماً (لأن السيرفر 422 بدونهم)
    final fn = (firstName?.trim().isNotEmpty == true)
        ? firstName!.trim()
        : current.user.firstName;

    final ln = (lastName?.trim().isNotEmpty == true)
        ? lastName!.trim()
        : current.user.lastName;

    // ✅ هذا هو اللي رح ينبعت للـ API
    final avatarPath = current.selectedAvatarPath; // ممكن null

    emit(current.copyWith(isSaving: true, message: null));

    final res = await repo.updateProfile(
      firstName: fn,
      lastName: ln,
      profileImagePath: avatarPath,
    );

    if (!res.ok) {
      emit(
        current.copyWith(
          isSaving: false,
          message: res.message ?? "فشل التحديث",
        ),
      );
      return;
    }

    // ✅ Reload me (مع الحفاظ على avatars + selectedAvatarPath)
    await load();

    final after = state;
    if (after is _Loaded) {
      emit(after.copyWith(isSaving: false, message: "Saved"));
    }
  }
}

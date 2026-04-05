import 'package:breezefood/features/auth/data/repo/auth_repository.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/home/data/repo/home_repository.dart';
import 'package:geolocator/geolocator.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repo;
  final AuthRepository authRepo;
  HomeResponse? homeData;

  HomeCubit(this.repo, this.authRepo) : super(const HomeState.initial());

  // ✅ لمنع تكرار الإرسال داخل نفس جلسة الكيوبت
  bool _sentLocationOnce = false;

  /// ✅ إرسال الموقع مرة واحدة فقط عند فتح التطبيق/الهوم
  /// - يطلب permission إذا لازم
  /// - يجلب current position
  /// - يرسل "موقعي الحالي"
  /// - لا يعمل تحديثات لاحقة (no stream)
  Future<void> sendMyLocationOnce() async {
    if (_sentLocationOnce) return;

    final ok = await _ensureLocationPermission();
    if (!ok) return;

    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await updateUserLocation(address: "موقعي الحالي", lat: pos.latitude, lon: pos.longitude);

      _sentLocationOnce = true;
    } catch (_) {
      // تجاهل: ممكن GPS ما رد مباشرة
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  String? userAddress;
  double? latUserAddress;
  double? lonUserAddress;

  Future<void> updateUserLocation({required String address, required double lat, required double lon}) async {
    final res = await authRepo.addAddress(address: address, latitude: lat, longitude: lon, isDefault: true);

    if (!res.ok) {
      return;
    }
    userAddress = address;
    latUserAddress = lat;
    lonUserAddress = lon;
    // await load();
  }

  Future<void> load({bool silent = false}) async {
    final prev = state.maybeWhen(loaded: (d) => d, orElse: () => null);

    if (!silent || prev == null) {
      emit(const HomeState.loading());
    }

    final res = await repo.getHome();
    if (!res.ok) {
      // لو silent ومعك prev، لا تطيّر الصفحة
      if (silent && prev != null) return;
      emit(HomeState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = HomeResponse.fromJson((res.data as Map).cast<String, dynamic>());
      homeData = parsed;
      emit(HomeState.loaded(parsed));
    } catch (_) {
      if (silent && prev != null) return;
      emit(const HomeState.error("فشل قراءة بيانات الصفحة الرئيسية"));
    }
  }
}

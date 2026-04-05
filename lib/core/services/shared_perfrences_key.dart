import 'package:hive/hive.dart';

class AuthStorageHelper {
  static const String _authBoxName = 'auth_box';
  static const String _userBack = 'user_back';
  static const String _prefsBoxName = 'app_prefs_box';
  static const String _them = 'them';
  static const String _themKey = 'themKey';

  static const String _tokenKey = 'auth_token';
  static const String _userBackKey = 'user_back_key';
  static const String _roleKey = 'user_role';
  static const String _isGuestKey = 'is_guest';

  static const String _zoomHintKey = 'verify_zoom_hint_dismissed_v1';
  static const String acceptConditionKey = 'accept_condition';

  // -----------------------
  // ✅ Location keys (Hive)
  // -----------------------
  static const String _userLocTextKey = 'user_loc_text';
  static const String _userLatKey = 'user_lat';
  static const String _userLonKey = 'user_lon';

  static const String _cartLocTextKey = 'cart_loc_text';
  static const String _cartLatKey = 'cart_lat';
  static const String _cartLonKey = 'cart_lon';

  // -------------------------------------------------------------
  // Guest Mode
  // -------------------------------------------------------------
  static Future<void> setGuestMode(bool value) async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(_isGuestKey, value);
  }

  static Future<bool> isGuest() async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(_isGuestKey, defaultValue: false);
  }

  static Future<void> clearGuestMode() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.delete(_isGuestKey);
  }

  ///
  /// them
  ///
  // -------------------------------------------------------------
  // ROLE
  // -------------------------------------------------------------
  static Future<void> saveThem(String? role) async {
    final box = await Hive.openBox(_them);
    await box.put(_themKey, role ?? 'dark');
  }

  static Future<String?> getThem() async {
    final box = await Hive.openBox(_them);
    return box.get(_themKey);
  }

  // -------------------------------------------------------------
  // ROLE
  // -------------------------------------------------------------
  static Future<void> saveUserRole(String role) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_roleKey, role);
  }

  static Future<String?> getUserRole() async {
    final box = await Hive.openBox(_authBoxName);
    return box.get(_roleKey);
  }

  static String? getUserRoleSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_roleKey) as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeUserRole() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_roleKey);
  }

  // -------------------------------------------------------------
  // TOKEN
  // -------------------------------------------------------------
  static Future<void> saveToken(String token) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final box = await Hive.openBox(_authBoxName);
    return box.get(_tokenKey);
  }

  static String? getTokenSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_tokenKey) as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeToken() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  ///
  ///
  static Future<void> saveBack(String back) async {
    final box = await Hive.openBox(_userBack);
    await box.put(_userBackKey, back);
  }

  static Future<String?> getBack() async {
    final box = await Hive.openBox(_userBack);
    return box.get(_userBackKey);
  }

  static Future<void> removeBack() async {
    final box = await Hive.openBox(_userBack);
    await box.delete(_userBackKey);
  }

  static Future<bool> hasBack() async {
    final back = await getToken();
    return back != null ? false : true;
  }

  // -------------------------------------------------------------
  // ZOOM HINT
  // -------------------------------------------------------------
  static Future<bool> isZoomHintDismissed() async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(_zoomHintKey, defaultValue: false) as bool;
  }

  static Future<void> dismissZoomHint() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(_zoomHintKey, true);
  }

  static Future<void> resetZoomHint() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.delete(_zoomHintKey);
  }

  // -------------------------------------------------------------
  // FLAGS
  // -------------------------------------------------------------
  static Future<void> setFlag(String key, bool value) async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(key, value);
  }

  static Future<bool?> getFlag(String key) async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(key) as bool?;
  }

  static Future<void> setAcceptCondition(bool accepted) async => setFlag(acceptConditionKey, accepted);

  static Future<bool?> getAcceptCondition() async => getFlag(acceptConditionKey);

  // =============================================================
  // ✅ USER LOCATION (Home default)
  // text صار OPTIONAL حتى ما يكسر verify/addAddress
  // lat/lon صاروا double
  // =============================================================
  static Future<void> saveUserLocation({String? text, required double lat, required double lon}) async {
    final box = await Hive.openBox(_authBoxName);

    if (text != null && text.trim().isNotEmpty) {
      await box.put(_userLocTextKey, text.trim());
    }

    await box.put(_userLatKey, lat);
    await box.put(_userLonKey, lon);
  }

  static Future<Map<String, dynamic>?> getUserLocation() async {
    final box = await Hive.openBox(_authBoxName);

    final text = box.get(_userLocTextKey) as String?;
    final lat = box.get(_userLatKey);
    final lon = box.get(_userLonKey);

    if (lat == null || lon == null) return null;

    return {"text": text, "lat": (lat as num).toDouble(), "lon": (lon as num).toDouble()};
  }

  static Future<void> removeUserLocation() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_userLocTextKey);
    await box.delete(_userLatKey);
    await box.delete(_userLonKey);
  }

  // =============================================================
  // ✅ CART LOCATION (only if user changed in cart)
  // =============================================================
  static Future<void> saveCartLocation({required String text, required double lat, required double lon}) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_cartLocTextKey, text.trim());
    await box.put(_cartLatKey, lat);
    await box.put(_cartLonKey, lon);
  }

  static Future<Map<String, dynamic>?> getCartLocation() async {
    final box = await Hive.openBox(_authBoxName);

    final text = box.get(_cartLocTextKey) as String?;
    final lat = box.get(_cartLatKey);
    final lon = box.get(_cartLonKey);

    if (text == null || text.trim().isEmpty) return null;
    if (lat == null || lon == null) return null;

    return {"text": text, "lat": (lat as num).toDouble(), "lon": (lon as num).toDouble()};
  }

  /// ✅ لما تغيّر موقعك من الهوم: خليه default جديد للجميع
  /// وبنفس الوقت صفّي cart_location حتى الكارت يتبع الجديد
  static Future<void> overrideHomeLocation({required String text, required double lat, required double lon}) async {
    await saveUserLocation(text: text, lat: lat, lon: lon);

    // ✅ خلي الكارت يرجع يتبع الـ user_location الجديد
    await clearCartLocation();
  }

  /// ✅ الموقع الفعلي للكارت: إذا في cart_location استخدمه
  /// وإلا استخدم user_location
  static Future<Map<String, dynamic>?> getEffectiveCartLocation() async {
    final cart = await getCartLocation();
    if (cart != null) return cart;
    return await getUserLocation();
  }

  static Future<void> clearCartLocation() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_cartLocTextKey);
    await box.delete(_cartLatKey);
    await box.delete(_cartLonKey);
  }
}

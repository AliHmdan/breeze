class FavoritesResponse {
  final List<FavoriteItem> myFavorites;

  FavoritesResponse({required this.myFavorites});

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _toStringSafe(dynamic v) => v == null ? "" : v.toString();

  static List<T> _list<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final v = json[key];
    if (v is List) {
      return v
          .where((e) => e is Map)
          .map((e) => fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    return <T>[];
  }

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      myFavorites: _list(json, "my_favorites", (e) => FavoriteItem.fromJson(e)),
    );
  }
}

// ✅ نفس اسم كلاسـك FavoriteItem بدون ما نغير UI
class FavoriteItem {
  final int id;
  final String nameAr;
  final String restaurantName;
  final double price;
  final String image;
  final int restaurantId;

  const FavoriteItem({
    required this.id,
    required this.nameAr,
    required this.restaurantName,
    required this.price,
    required this.image,
    required this.restaurantId,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: FavoritesResponse._toInt(json["id"]),
    price: FavoritesResponse._toDouble(json["price"]),
    image: FavoritesResponse._toStringSafe(json["image"]),
    nameAr: FavoritesResponse._toStringSafe(json["name_ar"]),
    restaurantName: FavoritesResponse._toStringSafe(json["restaurant_name"]),
    restaurantId: FavoritesResponse._toInt(json["restaurant_id"]),
  );
}

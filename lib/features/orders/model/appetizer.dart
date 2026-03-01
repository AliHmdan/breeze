import 'package:breezefood/core/component/url_helper.dart';

class Appetizer {
  final int id;
  final int restaurantId;
  final bool isAvailable;
  final String? image;
  final double price;
  final String nameAr;
  final String nameEn;

  Appetizer({
    required this.id,
    required this.restaurantId,
    required this.isAvailable,
    required this.image,
    required this.price,
    required this.nameAr,
    required this.nameEn,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v.toInt() == 1;
    final s = v.toString().toLowerCase();
    return s == "1" || s == "true" || s == "yes";
  }

  factory Appetizer.fromJson(Map<String, dynamic> json) {
    final imageRaw = json["image"]?.toString();

    return Appetizer(
      id: _toInt(json["id"]),
      restaurantId: _toInt(json["restaurant_id"]),
      isAvailable: _toBool(json["is_available"]),
      image: UrlHelper.toFullUrl(imageRaw),
      price: _toDouble(json["price"]),
      nameAr: (json["name_ar"] ?? "").toString(),
      nameEn: (json["name_en"] ?? "").toString(),
    );
  }
}

class AddressModel {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: (json["id"] ?? 0) is int ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
        address: (json["address"] ?? "").toString(),
        latitude: (json["latitude"] is num)
            ? (json["latitude"] as num).toDouble()
            : double.tryParse("${json["latitude"]}") ?? 0,
        longitude: (json["longitude"] is num)
            ? (json["longitude"] as num).toDouble()
            : double.tryParse("${json["longitude"]}") ?? 0,
        isDefault: (json["is_default"] == true) || (json["is_default"] == 1),
      );
}
class ProfileAddress {
  final int? id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? source;

  const ProfileAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.source,
  });

  bool get hasCoords => latitude.abs() > 0.000001 && longitude.abs() > 0.000001;

  factory ProfileAddress.fromJson(Map<String, dynamic> json) {
    return ProfileAddress(
      id: _toIntOrNull(json['id']),
      label: (json['label'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      isDefault: _toBool(json['is_default']),
      source: json['source']?.toString(),
    );
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().toLowerCase();
    return s == 'true' || s == '1';
  }
}
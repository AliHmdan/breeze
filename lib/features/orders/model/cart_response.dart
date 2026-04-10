import 'package:breezefood/core/services/translation_model.dart'
    show TranslationModel;

class CartResponse {
  final int orderId;
  final String orderStatus;
  final VipModel? vip;
  final int restaurantId;
  final String restaurantName;
  final String restaurantLogo;

  final CartPrimaryAddress? primaryAddress;
  final List<CartUserAddress> addresses;
  final List<CartItem> items;

  final List<CartAppetizer> appetizers;

  // ================= PRICING =================
  final double itemsTotalBefore;
  final double itemsTotalAfter;
  final double itemsDiscount;

  final double appetizersTotal;

  final double deliveryBefore;
  final double deliveryAfter;
  final double deliveryDiscount;

  final double grandBefore;
  final double grandAfter;

  CartResponse({
    required this.primaryAddress,
    required this.addresses,
    required this.orderId,
    required this.orderStatus,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantLogo,
    required this.items,
    required this.appetizers,
    required this.itemsTotalBefore,
    required this.itemsTotalAfter,
    required this.itemsDiscount,
    required this.appetizersTotal,
    required this.deliveryBefore,
    required this.deliveryAfter,
    required this.deliveryDiscount,
    required this.grandBefore,
    required this.grandAfter,
    required this.vip,
  });

  // ================= Helpers =================
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  // ================= FROM JSON =================
  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final order = (json["order"] as Map?)?.cast<String, dynamic>() ?? {};
    final restaurant =
        (json["restaurant"] as Map?)?.cast<String, dynamic>() ?? {};
    final pricing =
        (json["order_pricing"] as Map?)?.cast<String, dynamic>() ?? {};

    final itemsJson = (json["items"] as List? ?? const []);
    final items = itemsJson
        .where((e) => e is Map)
        .map((e) => CartItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final appetizersJson = (json["appetizers"] as List? ?? const []);
    final appetizers = appetizersJson
        .where((e) => e is Map)
        .map((e) => CartAppetizer.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final primaryJson = (json["primary_address"] as Map?)
        ?.cast<String, dynamic>();
    final primary = primaryJson == null
        ? null
        : CartPrimaryAddress.fromJson(primaryJson);

    final addressesJson = (json["addresses"] as List? ?? const []);
    final addresses = addressesJson
        .where((e) => e is Map)
        .map(
          (e) => CartUserAddress.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();

    // ✅ القيم الفعلية من السيرفر
    final itemsAfter = _toDouble(pricing["items_total_after"]);

    final appetizersTotal = _toDouble(pricing["appetizers_total"]) > 0
        ? _toDouble(pricing["appetizers_total"])
        : _toDouble(pricing["appetizersTotal"]);

    final deliveryBefore = _toDouble(pricing["delivery_fee_before"]);
    final deliveryAfter = _toDouble(pricing["delivery_fee_after"]);
    final deliveryDiscount = _toDouble(pricing["delivery_discount"]);

    // ✅ السيرفر يرجع grand_total فقط
    final grandTotal = _toDouble(pricing["grand_total"]);

    // ✅ fallback احتياطي
    final computedGrand = itemsAfter + deliveryAfter;

    return CartResponse(
      orderId: _toInt(order["id"]),
      orderStatus: (order["status"] ?? "").toString(),
      vip: VipModel.fromJson(json['vip']),
      restaurantId: _toInt(restaurant["id"]),
      restaurantName: (restaurant["name"] ?? "My Cart").toString(),
      restaurantLogo: (restaurant["logo"] ?? "").toString(),

      primaryAddress: primary,
      addresses: addresses,
      items: items,
      appetizers: appetizers,

      // ❌ غير موجودة بالريسبونس → محسوبة
      itemsTotalBefore: itemsAfter,
      itemsTotalAfter: itemsAfter,
      itemsDiscount: 0,

      appetizersTotal: appetizersTotal,

      deliveryBefore: deliveryBefore,
      deliveryAfter: deliveryAfter,
      deliveryDiscount: deliveryDiscount,

      // ❌ غير موجودة
      grandBefore: 0,
      // ✅ المهم
      grandAfter: grandTotal > 0 ? grandTotal : computedGrand,
    );
  }

  // ================= Convenience =================
  double get itemsTotal => itemsTotalAfter;
  double get appetizersTotalValue => appetizersTotal;
  double get deliveryFee => deliveryAfter;
  double get grandTotal => grandAfter;

  bool get hasAnyDiscount =>
      itemsTotalBefore > itemsTotalAfter || deliveryBefore > deliveryAfter;
  CartResponse copyWith({
    int? orderId,
    String? orderStatus,
    int? restaurantId,
    String? restaurantName,
    String? restaurantLogo,
    CartPrimaryAddress? primaryAddress,
    List<CartUserAddress>? addresses,
    List<CartItem>? items,
    List<CartAppetizer>? appetizers,
    double? itemsTotalBefore,
    double? itemsTotalAfter,
    double? itemsDiscount,
    double? appetizersTotal,
    double? deliveryBefore,
    double? deliveryAfter,
    double? deliveryDiscount,
    double? grandBefore,
    double? grandAfter,
  }) {
    return CartResponse(
      orderId: orderId ?? this.orderId,
      orderStatus: orderStatus ?? this.orderStatus,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantLogo: restaurantLogo ?? this.restaurantLogo,
      primaryAddress: primaryAddress ?? this.primaryAddress,
      addresses: addresses ?? this.addresses,
      items: items ?? this.items,
      appetizers: appetizers ?? this.appetizers,
      itemsTotalBefore: itemsTotalBefore ?? this.itemsTotalBefore,
      itemsTotalAfter: itemsTotalAfter ?? this.itemsTotalAfter,
      itemsDiscount: itemsDiscount ?? this.itemsDiscount,
      appetizersTotal: appetizersTotal ?? this.appetizersTotal,
      deliveryBefore: deliveryBefore ?? this.deliveryBefore,
      deliveryAfter: deliveryAfter ?? this.deliveryAfter,
      deliveryDiscount: deliveryDiscount ?? this.deliveryDiscount,
      grandBefore: grandBefore ?? this.grandBefore,
      grandAfter: grandAfter ?? this.grandAfter,
      vip: vip,
    );
  }
}

class CartAppetizer {
  final int id;
  final int appetizerId;
  final int quantity;

  CartAppetizer({
    required this.id,
    required this.appetizerId,
    required this.quantity,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory CartAppetizer.fromJson(Map<String, dynamic> json) {
    final nested = json["appetizer"];
    final nestedMap = (nested is Map) ? nested.cast<String, dynamic>() : null;

    final inferredAppetizerId = _toInt(json["appetizer_id"]) > 0
        ? _toInt(json["appetizer_id"])
        : _toInt(nestedMap?['id']) > 0
        ? _toInt(nestedMap?['id'])
        : _toInt(json["id"]);

    return CartAppetizer(
      id: _toInt(json["id"]),
      appetizerId: inferredAppetizerId,
      quantity: _toInt(json["quantity"]),
    );
  }
}

// =================================================
// ================= CART ITEM ======================
// =================================================

class CartItem {
  final int id;
  final int menuItemId;

  final String nameAr;
  final String nameEn;

  final int quantity;
  final int withSpicy;

  final double priceBefore;
  final double priceAfter;

  final int discountPercent;
  final String? discountType;

  final double extrasTotal;
  final double totalPrice;

  final String image;
  final int deliveryTime;

  final String? specialNotes;
  final List<CartExtra> extras;

  CartItem({
    required this.id,
    required this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    required this.quantity,
    required this.withSpicy,
    required this.priceBefore,
    required this.priceAfter,
    required this.discountPercent,
    required this.discountType,
    required this.extrasTotal,
    required this.totalPrice,
    required this.image,
    required this.deliveryTime,
    required this.specialNotes,
    required this.extras,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final qty = _toInt(json["quantity"]);
    final before = _toDouble(json["price_before"]);
    final after = _toDouble(json["price_after"]);
    final unit = after > 0 ? after : before;

    final extrasJson = (json["extras"] as List? ?? const []);
    final extras = extrasJson
        .where((e) => e is Map)
        .map((e) => CartExtra.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final total = _toDouble(json["total_price"]);
    final safeTotal = total > 0
        ? total
        : (unit * qty) + _toDouble(json["extras_total"]);

    return CartItem(
      id: _toInt(json["id"]),
      menuItemId: _toInt(json["menu_item_id"]),
      nameAr: (json["name_ar"] ?? "").toString(),
      nameEn: (json["name_en"] ?? "").toString(),
      quantity: qty,
      withSpicy: _toInt(json["with_Spicy"]),
      priceBefore: before,
      priceAfter: unit,
      discountPercent: _toInt(json["discount_percent"]),
      discountType: json["discount_type"]?.toString(),
      extrasTotal: _toDouble(json["extras_total"]),
      totalPrice: safeTotal,
      image: (json["image"] ?? "").toString(),
      deliveryTime: _toInt(json["delivery_time"]),
      specialNotes: json["special_notes"]?.toString(),
      extras: extras,
    );
  }

  bool get isSpicy => withSpicy == 1;
  bool get hasDiscount => discountPercent > 0 || priceBefore > priceAfter;
  double get unitPrice => priceAfter;
  CartItem copyWith({
    int? id,
    int? menuItemId,
    String? nameAr,
    String? nameEn,
    int? quantity,
    int? withSpicy,
    String? specialNotes,
    double? priceBefore,
    double? priceAfter,
    int? discountPercent,
    String? discountType,
    double? extrasTotal,
    double? totalPrice,
    String? image,
    int? deliveryTime,
    List<CartExtra>? extras,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      quantity: quantity ?? this.quantity,
      withSpicy: withSpicy ?? this.withSpicy,
      specialNotes: specialNotes ?? this.specialNotes,
      priceBefore: priceBefore ?? this.priceBefore,
      priceAfter: priceAfter ?? this.priceAfter,
      discountPercent: discountPercent ?? this.discountPercent,
      discountType: discountType ?? this.discountType,
      extrasTotal: extrasTotal ?? this.extrasTotal,
      totalPrice: totalPrice ?? this.totalPrice,
      image: image ?? this.image,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      extras: extras ?? this.extras,
    );
  }
}

class CartExtra {
  final int id;
  final int extraId;
  final int quantity;
  final int withSpicy;

  final double unitPrice;
  final double totalPrice;

  final TranslationModel? nameArObj;
  final TranslationModel? nameEnObj;

  CartExtra({
    required this.id,
    required this.extraId,
    required this.quantity,
    required this.withSpicy,
    required this.unitPrice,
    required this.totalPrice,
    this.nameArObj,
    this.nameEnObj,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory CartExtra.fromJson(Map<String, dynamic> json) {
    final ar = json["name_ar"];
    final en = json["name_en"];

    return CartExtra(
      id: _toInt(json["id"]),
      extraId: _toInt(json["extra_id"]),
      quantity: _toInt(json["quantity"]),
      withSpicy: _toInt(json["with_Spicy"]),
      unitPrice: _toDouble(json["unit_price"]),
      totalPrice: _toDouble(json["total_price"]),
      nameArObj: ar is Map
          ? TranslationModel.fromJson(ar.cast<String, dynamic>())
          : null,
      nameEnObj: en is Map
          ? TranslationModel.fromJson(en.cast<String, dynamic>())
          : null,
    );
  }

  bool get isSpicy => withSpicy == 1;
}

// =================================================
// ================= ADDRESSES =====================
// =================================================

class CartPrimaryAddress {
  final String? address;
  final double latitude;
  final double longitude;

  CartPrimaryAddress({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory CartPrimaryAddress.fromJson(Map<String, dynamic> json) {
    return CartPrimaryAddress(
      address: json["address"]?.toString(),
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
    );
  }
}

class CartUserAddress {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  CartUserAddress({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
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
    if (v is num) return v == 1;
    final s = v.toString().toLowerCase();
    return s == "true" || s == "1";
  }

  factory CartUserAddress.fromJson(Map<String, dynamic> json) {
    return CartUserAddress(
      id: _toInt(json["id"]),
      address: (json["address"] ?? "").toString(),
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      isDefault: _toBool(json["is_default"]),
    );
  }
}

class VipModel {
  int? id;
  int? price;
  List<Images>? images;

  VipModel({this.id, this.price, this.images});

  VipModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // price = json['price'];
    price = json['price'] is int
        ? json['price']
        : int.tryParse(json['price'].toString());
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['price'] = this.price;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  int? id;
  int? vipId;
  int? orderImage;
  String? path;
  String? createdAt;
  String? updatedAt;

  Images({
    this.id,
    this.vipId,
    this.orderImage,
    this.path,
    this.createdAt,
    this.updatedAt,
  });

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vipId = json['vip_id'];
    orderImage = json['order_image'];
    path = json['path'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['vip_id'] = this.vipId;
    data['order_image'] = this.orderImage;
    data['path'] = this.path;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

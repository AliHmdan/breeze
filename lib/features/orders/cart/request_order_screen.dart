import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:breezefood/core/component/dialogs.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/orders/data/repo/appetizers_repository.dart';

import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/orders/model/appetizer.dart';
import 'package:breezefood/features/orders/model/cart_response.dart';
import 'package:breezefood/features/orders/model/store_order_request.dart';
import 'package:breezefood/features/orders/payment_method.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';

import 'package:breezefood/features/orders/request_order/counter_request.dart';
import 'package:breezefood/features/orders/request_order/meal_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'address_section.dart';
import 'location_helper.dart';
import 'temp_address_map_picker.dart';

class RequestOrderScreen extends StatefulWidget {
  const RequestOrderScreen({super.key});

  @override
  State<RequestOrderScreen> createState() => _RequestOrderScreenState();
}

class _RequestOrderScreenState extends State<RequestOrderScreen> {
  // ✅ address (always current unless user changes)
  OrderAddress? _tempOrderAddress;
  final TextEditingController _tempDetailsCtrl = TextEditingController();
  final FocusNode _tempDetailsFocus = FocusNode();

  // ✅ order notes
  final TextEditingController _orderNotesCtrl = TextEditingController();

  // ✅ per-item notes
  final Map<int, String> _itemNotes = {}; // key = cartItemId

  // ✅ delivery type
  String _deliveryType = "delivery"; // "pickup" | "delivery"

  String _selectedPayment = 'cash';

  // VIP state
  bool _isVipEnabled = false;

  // Appetizers (Recommended to you)
  bool _loadingAppetizers = false;
  String? _appetizersError;
  int? _appetizersRestaurantId;
  List<Appetizer> _appetizers = const [];

  final Map<int, int> _appetizerQty = {}; // key=appetizerId
  final Set<int> _syncingAppetizers = {};

  int? _lastCartRestaurantId;

  final methods = const [
    PaymentMethod(
      id: 'cash',
      title: 'Cash',
      imageAsset: 'assets/images/cash.png',
      imageWidth: 36,
      imageHeight: 24,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillCurrentLocation();
    });
  }

  @override
  void dispose() {
    _tempDetailsCtrl.dispose();
    _tempDetailsFocus.dispose();
    _orderNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAppetizers(int restaurantId) async {
    if (_loadingAppetizers) return;
    if (_appetizersRestaurantId == restaurantId && _appetizers.isNotEmpty) {
      return;
    }

    setState(() {
      _loadingAppetizers = true;
      _appetizersError = null;
      _appetizersRestaurantId = restaurantId;
      _appetizers = const [];
    });

    try {
      final repo = getIt<AppetizersRepository>();
      final res = await repo.getAppetizers(restaurantId);

      if (!mounted) return;

      if (!res.ok) {
        setState(() {
          _appetizersError = res.message ?? "Failed to load appetizers";
          _loadingAppetizers = false;
        });
        return;
      }

      final data = (res.data as List? ?? const []);
      final items = data
          .where((e) => e is Map)
          .map((e) => Appetizer.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      setState(() {
        _appetizers = items;
        _loadingAppetizers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _appetizersError = "Failed to load appetizers";
        _loadingAppetizers = false;
      });
    }
  }

  Future<void> _syncAppetizer({
    required int appetizerId,
    required int quantity,
  }) async {
    if (_syncingAppetizers.contains(appetizerId)) return;

    setState(() {
      _syncingAppetizers.add(appetizerId);
    });

    try {
      final repo = getIt<AppetizersRepository>();
      final res = await repo.syncAppetizers(
        appetizers: [
          {"appetizer_id": appetizerId, "quantity": quantity},
        ],
      );

      if (!mounted) return;

      if (!res.ok) {
        setState(() {
          _syncingAppetizers.remove(appetizerId);
        });
        return;
      }

      await context.read<CartCubit>().loadCart(silent: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _syncingAppetizers.remove(appetizerId);
      });
    }
  }

  Widget _recommendedAppetizersSection({
    required bool isRTL,
    required CartResponse cart,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadingAppetizers) {
      return Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Row(
          children: [
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              "cart.recommended_loading".tr(),
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.75),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_appetizersError != null) {
      return const SizedBox.shrink();
    }

    if (_appetizers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "cart.people_also_added".tr(),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 230.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _appetizers.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, i) {
                final a = _appetizers[i];
                final qty = _appetizerQty[a.id] ?? 0;
                final syncing = _syncingAppetizers.contains(a.id);
                final disabled = syncing || !a.isAvailable;

                final title = isRTL
                    ? (a.nameAr.trim().isNotEmpty ? a.nameAr : a.nameEn)
                    : (a.nameEn.trim().isNotEmpty ? a.nameEn : a.nameAr);

                return SizedBox(
                  width: 170.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14.r),
                            topRight: Radius.circular(14.r),
                          ),
                          child: Stack(
                            children: [
                              (a.image == null || a.image!.isEmpty)
                                  ? Image.asset(
                                      "assets/images/003.jpg",
                                      width: double.infinity,
                                      height: 120.h,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      a.image!,
                                      width: double.infinity,
                                      height: 120.h,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        "assets/images/003.jpg",
                                        width: double.infinity,
                                        height: 120.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                              Positioned(
                                top: 8.h,
                                left: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    "cart.popular".tr(),
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                context.syp(a.price),
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  if (qty <= 0)
                                    InkWell(
                                      onTap: disabled
                                          ? null
                                          : () {
                                              setState(() {
                                                _appetizerQty[a.id] = 1;
                                              });
                                              _syncAppetizer(
                                                appetizerId: a.id,
                                                quantity: 1,
                                              );
                                            },
                                      child: Container(
                                        width: 38.w,
                                        height: 38.w,
                                        decoration: BoxDecoration(
                                          color: disabled
                                              ? colorScheme
                                                    .surfaceContainerHighest
                                              : colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.outline
                                                .withOpacity(0.22),
                                          ),
                                        ),
                                        child: syncing
                                            ? Padding(
                                                padding: EdgeInsets.all(10.w),
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color:
                                                          colorScheme.primary,
                                                    ),
                                              )
                                            : Icon(
                                                Icons.add,
                                                color: disabled
                                                    ? colorScheme.onSurface
                                                          .withOpacity(0.35)
                                                    : colorScheme.primary,
                                              ),
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 38.w,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: colorScheme.outline
                                              .withOpacity(0.22),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: disabled
                                                ? null
                                                : () {
                                                    final next = (qty - 1)
                                                        .clamp(0, 99);
                                                    setState(() {
                                                      if (next == 0) {
                                                        _appetizerQty.remove(
                                                          a.id,
                                                        );
                                                      } else {
                                                        _appetizerQty[a.id] =
                                                            next;
                                                      }
                                                    });
                                                    _syncAppetizer(
                                                      appetizerId: a.id,
                                                      quantity: next,
                                                    );
                                                  },
                                            child: SizedBox(
                                              width: 38.w,
                                              height: 38.w,
                                              child: Icon(
                                                Icons.remove,
                                                color: disabled
                                                    ? colorScheme.onSurface
                                                          .withOpacity(0.35)
                                                    : colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 28.w,
                                            child: Center(
                                              child: syncing
                                                  ? SizedBox(
                                                      width: 14.w,
                                                      height: 14.w,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: colorScheme
                                                                .primary,
                                                          ),
                                                    )
                                                  : Text(
                                                      qty.toString(),
                                                      style: TextStyle(
                                                        color: colorScheme
                                                            .onSurface,
                                                        fontSize: 13.sp,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: disabled
                                                ? null
                                                : () {
                                                    final next = (qty + 1)
                                                        .clamp(0, 99);
                                                    setState(() {
                                                      _appetizerQty[a.id] =
                                                          next;
                                                    });
                                                    _syncAppetizer(
                                                      appetizerId: a.id,
                                                      quantity: next,
                                                    );
                                                  },
                                            child: SizedBox(
                                              width: 38.w,
                                              height: 38.w,
                                              child: Icon(
                                                Icons.add,
                                                color: disabled
                                                    ? colorScheme.onSurface
                                                          .withOpacity(0.35)
                                                    : colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Location behavior
  // ----------------------------

  Future<void> _prefillCurrentLocation() async {
    if (_tempOrderAddress != null) return;

    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    // 1) ✅ Try effective saved location (cart -> user)
    final saved = await AuthStorageHelper.getEffectiveCartLocation();
    if (!mounted) return;

    if (saved != null) {
      final text = (saved["text"] ?? "").toString().trim();
      final lat = (saved["lat"] as num).toDouble();
      final lon = (saved["lon"] as num).toDouble();

      final fallback = isRTL ? "موقعي الحالي" : "My current location";
      final finalText = text.isNotEmpty ? text : fallback;

      setState(() {
        _tempOrderAddress = OrderAddress(
          text: finalText,
          latitude: lat,
          longitude: lon,
        );
        _tempDetailsCtrl.text = finalText;
      });
      return;
    }

    // 2) ✅ Fallback to GPS
    try {
      final pos = await LocationHelper.getCurrentPosition();
      if (!mounted) return;

      final fallback = isRTL ? "موقعي الحالي" : "My current location";

      final text = await LocationHelper.reverseGeocodeText(
        lat: pos.latitude,
        lng: pos.longitude,
        fallback: fallback,
      );

      setState(() {
        _tempOrderAddress = OrderAddress(
          text: text,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        _tempDetailsCtrl.text = text;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? "تعذر تحديد موقعك الحالي، اضغط تغيير لاختيار موقع"
                : "Couldn't get your location. Tap Change to pick one.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changeLocation({required bool isRTL}) async {
    final init = _tempOrderAddress == null
        ? null
        : LatLng(_tempOrderAddress!.latitude, _tempOrderAddress!.longitude);

    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => TempAddressMapPicker(isRTL: isRTL, initial: init),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _tempOrderAddress = OrderAddress(
        text: (result["text"] ?? "").toString(),
        latitude: (result["lat"] as num).toDouble(),
        longitude: (result["lng"] as num).toDouble(),
      );
      _tempDetailsCtrl.text = _tempOrderAddress!.text;
    });

    await AuthStorageHelper.saveCartLocation(
      text: _tempOrderAddress!.text,
      lat: _tempOrderAddress!.latitude,
      lon: _tempOrderAddress!.longitude,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tempDetailsFocus.requestFocus();
    });
  }

  // ----------------------------
  // Item note dialog
  // ----------------------------

  Future<void> _editItemNote({
    required bool isRTL,
    required CartItem item,
  }) async {
    final ctrl = TextEditingController(text: _itemNotes[item.id] ?? "");

    // final ok = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     backgroundColor: AppColor.black,
    //     title: Text(
    //       isRTL ? "ملاحظة للوجبة" : "Item note",
    //       style: const TextStyle(
    //         color: Colors.white,
    //         fontWeight: FontWeight.w700,
    //       ),
    //     ),
    //     content: TextField(
    //       controller: ctrl,
    //       maxLines: 3,
    //       style: const TextStyle(color: Colors.white),
    //       decoration: InputDecoration(
    //         hintText: isRTL
    //             ? "مثلاً: بدون بصل، سبايسي خفيف..."
    //             : "e.g. No onion, mild spicy...",
    //         hintStyle: const TextStyle(color: Colors.white54),
    //         filled: true,
    //         fillColor: Colors.white10,
    //         border: OutlineInputBorder(
    //           borderRadius: BorderRadius.circular(12.r),
    //           borderSide: BorderSide.none,
    //         ),
    //       ),
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: Text(isRTL ? "إلغاء" : "Cancel"),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, true),
    //         child: Text(isRTL ? "حفظ" : "Save"),
    //       ),
    //     ],
    //   ),
    // );

    // if (ok == true) {
    //   setState(() {
    //     final v = ctrl.text.trim();
    //     if (v.isEmpty) {
    //       _itemNotes.remove(item.id);
    //     } else {
    //       _itemNotes[item.id] = v;
    //     }
    //   });
    // }
  }

  // ----------------------------
  // Delete confirmation
  // ----------------------------

  Future<bool> _confirmDelete(
    BuildContext context, {
    required bool isRTL,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              isRTL ? "حذف العنصر؟" : "Delete item?",
              style: TextStyle(color: colorScheme.onSurface),
            ),
            content: Text(
              isRTL
                  ? "هل تريد حذف هذا العنصر من السلة؟"
                  : "Do you want to remove this item from cart?",
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isRTL ? "إلغاء" : "Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(isRTL ? "حذف" : "Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ----------------------------
  // Build order request
  // ----------------------------

  List<OrderExtraRequest> _extrasPayload(CartItem it) {
    return it.extras
        .map((e) => OrderExtraRequest(extraId: e.extraId, quantity: e.quantity))
        .toList();
  }

  Future<void> _storeOrder(
    BuildContext context,
    CartResponse cart,
    bool isVip,
    String paymentId,
  ) async {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    final hasTemp =
        _tempOrderAddress != null &&
        _tempOrderAddress!.latitude != 0 &&
        _tempOrderAddress!.longitude != 0;

    if (_deliveryType == "delivery" && !hasTemp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? "تعذر تحديد عنوان. اضغط تغيير لاختيار موقع"
                : "No address. Tap Change to pick a location",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final addressToSend = _tempOrderAddress!;

    // items
    final items = cart.items.map((it) {
      return OrderItemRequest(
        menuItemId: it.menuItemId,
        quantity: it.quantity,
        specialNotes: (it.specialNotes ?? "").trim(),

        extras: _extrasPayload(it),
      );
    }).toList();

    final req = StoreOrderRequest(
      restaurantId: cart.restaurantId,
      deliveryType: _deliveryType,
      paymentMethod: paymentId,
      notes: _orderNotesCtrl.text.trim(),
      deliveryFee: cart.deliveryAfter,
      address: addressToSend,
      items: items,
      appetizers: const [],
      isVip: isVip,
    );

    context.read<OrderFlowCubit>().store(req);
  }

  // ----------------------------
  // UI
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final title = state.maybeWhen(
                cartLoaded: (cart, updatingIds, toast, isRefreshing) =>
                    cart.restaurantName.isNotEmpty
                    ? cart.restaurantName
                    : (isRTL ? "سلّتي" : "My Cart"),
                orElse: () => isRTL ? "سلّتي" : "My Cart",
              );

              return CustomAppbarProfile(
                title: title,
                icon: Icons.arrow_back_ios,
                ontap: () => Navigator.pop(context),
                backgroundcolor: Colors.transparent,
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background_auth.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: colorScheme.surface.withOpacity(0.85)),
          ),
          SafeArea(
            child: BlocListener<OrderFlowCubit, OrderFlowState>(
              listener: (context, state) async {
                await state.maybeWhen(
                  loading: () async {
                    if (!EasyLoading.isShow) {
                      EasyLoading.show(
                        status: isRTL
                            ? "جارٍ إرسال الطلب..."
                            : "Placing order...",
                      );
                    }
                  },
                  success: (orderId, status, pricing, raw) async {
                    if (EasyLoading.isShow) await EasyLoading.dismiss();
                    if (!context.mounted) return;

                    await AppDialog.showSuccessDialog(
                      title: isRTL
                          ? "تم إرسال الطلب بنجاح"
                          : "Order placed successfully",
                      message: isRTL
                          ? "رقم الطلب: #$orderId\nالحالة: $status"
                          : "Order ID: #$orderId\nStatus: $status",
                    );

                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  },
                  error: (msg) async {
                    if (EasyLoading.isShow) await EasyLoading.dismiss();
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isRTL ? "❌ فشل إنشاء الطلب: $msg" : "❌ Failed: $msg",
                        ),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  orElse: () async {
                    if (EasyLoading.isShow) await EasyLoading.dismiss();
                  },
                );
              },
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (msg) => Center(
                      child: Text(
                        msg,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                    cartLoaded: (cart, updatingIds, toast, isRefreshing) {
                      if (_lastCartRestaurantId != cart.restaurantId) {
                        _appetizerQty.clear();
                        _lastCartRestaurantId = cart.restaurantId;
                      }

                      for (final a in cart.appetizers) {
                        if (a.appetizerId > 0 && a.quantity > 0) {
                          _appetizerQty[a.appetizerId] = a.quantity;
                        }
                      }

                      if (cart.restaurantId > 0 &&
                          _appetizersRestaurantId != cart.restaurantId &&
                          !_loadingAppetizers) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          _loadAppetizers(cart.restaurantId);
                        });
                      }

                      final isPlacingOrder = context
                          .watch<OrderFlowCubit>()
                          .state
                          .maybeWhen(loading: () => true, orElse: () => false);

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          child: Column(
                            children: [
                              if (toast != null && toast.trim().isNotEmpty)
                                _ToastBox(toast: toast),

                              SizedBox(height: 10.h),

                              if (cart.items.isEmpty)
                                _EmptyCart(isRTL: isRTL)
                              else
                                _CartItemsSection(
                                  cart: cart,
                                  isRTL: isRTL,
                                  updatingIds: updatingIds,
                                  itemNotes: _itemNotes,
                                  onEditNote: (it) =>
                                      _editItemNote(isRTL: isRTL, item: it),
                                  onDelete: (it) async {
                                    final ok = await _confirmDelete(
                                      context,
                                      isRTL: isRTL,
                                    );
                                    if (!ok) return;

                                    context.read<CartCubit>().removeItem(it.id);
                                    setState(() => _itemNotes.remove(it.id));
                                  },
                                  onQtyChange: (it, newQty) {
                                    context.read<CartCubit>().updateQty(
                                      cartItemId: it.id,
                                      quantity: newQty,
                                    );
                                  },
                                ),

                              SizedBox(height: 10.h),

                              _recommendedAppetizersSection(
                                isRTL: isRTL,
                                cart: cart,
                              ),

                              if (_appetizers.isNotEmpty)
                                SizedBox(height: 10.h),

                              if (_deliveryType == "delivery") ...[
                                AddressSection(
                                  isRTL: isRTL,
                                  address: _tempOrderAddress,
                                  onChangeTap: () =>
                                      _changeLocation(isRTL: isRTL),
                                  detailsCtrl: _tempDetailsCtrl,
                                  detailsFocus: _tempDetailsFocus,
                                  onDetailsChanged: (v) {
                                    if (_tempOrderAddress == null) return;
                                    setState(() {
                                      _tempOrderAddress = OrderAddress(
                                        text: v.trim(),
                                        latitude: _tempOrderAddress!.latitude,
                                        longitude: _tempOrderAddress!.longitude,
                                      );
                                    });
                                  },
                                ),
                                SizedBox(height: 10.h),
                              ],

                              // VIP Section
                              if (cart.vip != null)
                                _VipSection(
                                  vip: cart.vip!,
                                  isVipEnabled: _isVipEnabled,
                                  onToggleVip: (enabled) {
                                    setState(() {
                                      _isVipEnabled = enabled;
                                    });
                                  },
                                ),

                              _TotalsSection(
                                cart: cart,
                                isVipEnabled: _isVipEnabled,
                              ),

                              SizedBox(height: 10.h),
                              _OrderNotesSection(
                                ctrl: _orderNotesCtrl,
                                isRTL: isRTL,
                              ),

                              SizedBox(height: 10.h),

                              PaymentMethodSection(
                                amountText: context.money(
                                  cart.grandAfter +
                                      (_isVipEnabled
                                          ? (cart.vip?.price?.toDouble() ?? 0.0)
                                          : 0.0),
                                ),
                                methods: methods,
                                initialSelectedId: _selectedPayment,
                                onChanged: (id) =>
                                    setState(() => _selectedPayment = id),
                                onOrder: isPlacingOrder
                                    ? null
                                    : (paymentId) => _storeOrder(
                                        context,
                                        cart,
                                        _isVipEnabled,
                                        paymentId,
                                      ),
                              ),

                              SizedBox(height: 18.h),
                            ],
                          ),
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------
// Sections widgets
// ----------------------------

class _ToastBox extends StatelessWidget {
  final String toast;
  const _ToastBox({required this.toast});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.error.withOpacity(0.35)),
      ),
      child: Text(
        toast,
        style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 12),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final bool isRTL;
  const _EmptyCart({required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: 30.h, bottom: 10.h),
      child: Text(
        isRTL ? "السلة فارغة" : "Cart is empty",
        style: TextStyle(color: colorScheme.onSurface, fontSize: 16.sp),
      ),
    );
  }
}

class _CartItemsSection extends StatelessWidget {
  final CartResponse cart;
  final bool isRTL;
  final Set<int> updatingIds;
  final Map<int, String> itemNotes;

  final void Function(CartItem it) onEditNote;
  final void Function(CartItem it) onDelete;
  final void Function(CartItem it, int newQty) onQtyChange;

  const _CartItemsSection({
    required this.cart,
    required this.isRTL,
    required this.updatingIds,
    required this.itemNotes,
    required this.onEditNote,
    required this.onDelete,
    required this.onQtyChange,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: cart.items.map((it) {
        final isUpdating = updatingIds.contains(it.id);

        final title = isRTL
            ? (it.nameAr.trim().isNotEmpty ? it.nameAr : it.nameEn)
            : (it.nameEn.trim().isNotEmpty ? it.nameEn : it.nameAr);

        final note = (it.specialNotes ?? "").trim();

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Slidable(
            key: ValueKey("cart_item_${it.id}"),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.22,
              children: [
                SlidableAction(
                  onPressed: isUpdating ? null : (_) => onDelete(it),
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  icon: Icons.delete_outline,
                  label: isRTL ? "حذف" : "Delete",
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.25),
                ),
              ),
              child: Column(
                children: [
                  MealCard(
                    key: ValueKey(it.id),
                    image: it.image,
                    name: title,
                    price: it.unitPrice,
                    counter: CounterRequest(
                      value: it.quantity,
                      loading: isUpdating,
                      onChanged: (newQty) => onQtyChange(it, newQty),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 12.w,
                  //     vertical: 8.h,
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       InkWell(
                  //         onTap: () => onEditNote(it),
                  //         borderRadius: BorderRadius.circular(10.r),
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(
                  //             horizontal: 10.w,
                  //             vertical: 6.h,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white10,
                  //             borderRadius: BorderRadius.circular(10.r),
                  //             border: Border.all(color: Colors.white12),
                  //           ),
                  //           child: Row(
                  //             children: [
                  //               const Icon(
                  //                 Icons.edit_note,
                  //                 color: Colors.white70,
                  //                 size: 18,
                  //               ),
                  //               SizedBox(width: 6.w),
                  //               Text(
                  //                 isRTL ? "ملاحظة" : "Note",
                  //                 style: TextStyle(
                  //                   color: Colors.white70,
                  //                   fontSize: 12.sp,
                  //                   fontWeight: FontWeight.w700,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(width: 10.w),
                  //       Expanded(
                  //         child: Text(
                  //           note.isEmpty
                  //               ? (isRTL ? "لا توجد ملاحظة" : "No note")
                  //               : note,
                  //           maxLines: 2,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: TextStyle(
                  //             color: Colors.white54,
                  //             fontSize: 12.sp,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TotalsSection extends StatelessWidget {
  final CartResponse cart;
  final bool isVipEnabled;

  const _TotalsSection({required this.cart, this.isVipEnabled = false});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate VIP price if enabled
    final vipPrice = isVipEnabled ? (cart.vip?.price?.toDouble() ?? 0.0) : 0.0;
    final totalWithVip = cart.grandAfter + vipPrice;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          _totalLine(
            title: isRTL ? "المجموع الفرعي" : "Sub total",
            value: cart.itemsTotalAfter,
            before: cart.itemsTotalBefore,
            money: (n) => context.syp(n),
            context: context,
          ),
          if (cart.appetizersTotal > 0)
            _totalLine(
              title: isRTL ? "المقبلات" : "Appetizers",
              value: cart.appetizersTotal,
              money: (n) => context.syp(n),
              context: context,
            ),
          _totalLine(
            title: isRTL ? "التوصيل" : "Delivery",
            value: cart.deliveryAfter,
            before: cart.deliveryBefore,
            money: (n) => context.syp(n),
            context: context,
          ),

          // VIP line if enabled
          if (isVipEnabled && vipPrice > 0)
            _totalLine(
              title: isRTL ? "خدمة VIP" : "VIP Service",
              value: vipPrice.toDouble(),
              money: (n) => context.syp(n),
              context: context,
            ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: colorScheme.outline.withOpacity(0.25),
              indent: 4.w,
              endIndent: 4.w,
            ),
          ),
          _totalLine(
            title: isRTL ? "الإجمالي" : "Total",
            value: totalWithVip,
            before: vipPrice > 0 ? cart.grandBefore : null,
            isTotal: true,
            money: (n) => context.syp(n),
            context: context,
          ),
        ],
      ),
    );
  }
}

class _OrderNotesSection extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isRTL;

  const _OrderNotesSection({required this.ctrl, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: 3,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: isRTL
              ? "ملاحظات للطلب (اختياري) مثال: اتصل قبل الوصول..."
              : "Order notes (optional) e.g. call before arrival...",
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12.sp,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// VIP Section
// ----------------------------
class _VipSection extends StatelessWidget {
  final VipModel vip;
  final bool isVipEnabled;
  final ValueChanged<bool> onToggleVip;

  const _VipSection({
    required this.vip,
    required this.isVipEnabled,
    required this.onToggleVip,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isVipEnabled
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isVipEnabled
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.25),
        ),
      ),
      child: InkWell(
        onTap: () => _showVipPopup(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            // VIP Crown Icon
            Icon(
              Icons.emoji_events,
              color: isVipEnabled
                  ? const Color(0xFFFFD700)
                  : const Color(0xFFFFD700).withOpacity(0.7),
              size: 25.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? "خدمة VIP" : "VIP Service",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isRTL
                        ? "سعر الخدمة: ${context.money(vip.price ?? 0)}"
                        : "Service price: ${context.money(vip.price ?? 0)}",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isVipEnabled
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                isVipEnabled
                    ? (isRTL ? "مفعل" : "Enabled")
                    : (isRTL ? "تفعيل" : "Enable"),
                style: TextStyle(
                  color: isVipEnabled
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVipPopup(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
        contentPadding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
        backgroundColor: colorScheme.surface,
        title: SizedBox(
          width: w * 0.92,
          child: Text(
            isRTL ? "خدمة VIP" : "VIP Service",
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        content: SizedBox(
          width: w * 0.92,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // VIP Images
              if (vip.images != null && vip.images!.isNotEmpty)
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.h,
                    crossAxisSpacing: 8.w,
                    childAspectRatio: 0.6,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vip.images!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final image = vip.images![index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        UrlHelper.toFullUrl(image.path ?? '') ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRTL ? "إلغاء" : "Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onToggleVip(!isVipEnabled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
              isVipEnabled
                  ? (isRTL ? "إلغاء التفعيل" : "Disable")
                  : (isRTL ? "تفعيل" : "Enable"),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------
// Total line helper (كما كان)
// ----------------------------
Widget _totalLine({
  required String title,
  required double value,
  double? before,
  bool isTotal = false,
  required String Function(num v) money,
  required BuildContext context,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final hasBefore = before != null && before! > value;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isTotal
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withOpacity(0.8),
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        if (hasBefore) ...[
          Text(
            money(before!),
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Text(
          money(value),
          style: TextStyle(
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
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
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:breezefood/features/profile/data/model/address_model.dart';
import 'package:breezefood/features/profile/data/repo/profile_repository.dart';
import 'package:breezefood/features/main_shell.dart';
import 'package:geocoding/geocoding.dart'
    show Placemark, placemarkFromCoordinates;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'address_section.dart';
import 'location_helper.dart';
import 'temp_address_map_picker.dart';

class RequestOrderScreen extends StatefulWidget {
  const RequestOrderScreen({
    super.key,
    // required this.addressTitle
  });

  // final String addressTitle;

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

  ///
  /// here to init the location from home
  ///
  Future<void> getAddressFromLatLon({
    required double lat,
    required double lon,
  }) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, lon);

    Placemark place = placeMarks[0];

    print(place.street);
    print(place.locality);
    print(place.country);
    _tempDetailsCtrl.text =
        '${place.country} ${place.locality} ${place.street}';
  }

  ///
  /// here for get the current location
  ///
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void getLatLon() async {
    try {
      Position pos = await determinePosition();

      double lat = pos.latitude;
      double lon = pos.longitude;

      getAddressFromLatLon(lat: lat, lon: lon);
      Navigator.pop(context, {
        "kind": "saved",
        "text": _tempDetailsCtrl.text,
        "lat": lat,
        "lon": lon,
      });
      _tempOrderAddress = OrderAddress(
        text: _tempDetailsCtrl.text,
        latitude: lat,
        longitude: lon,
      );
      _prefillCurrentLocation();

      print("Latitude: $lat");
      print("Longitude: $lon");
    } catch (e) {
      print("Error: $e");
    }
  }

  ///

  @override
  void initState() {
    super.initState();
    _tempOrderAddress = OrderAddress(
      text: context.read<HomeCubit>().userAddress ?? '',
      latitude: context.read<HomeCubit>().latUserAddress ?? 0,
      longitude: context.read<HomeCubit>().lonUserAddress ?? 0,
    );
    print('???????????????????????????????');
    print('???????????????????????????????');
    print('${_tempOrderAddress!.latitude}');
    print('${_tempOrderAddress!.longitude}');
    print('???????????????????????????????');
    print('???????????????????????????????');

    // _tempDetailsCtrl.text = context.read<HomeCubit>().userAddress ?? '';

    // print('?????????????????????????????????????');
    // print('?????????????????????????????????????');
    // print('${context.read<HomeCubit>().userAddress}');
    // print('${context.read<HomeCubit>().latUserAddress}');
    // print('${context.read<HomeCubit>().lonUserAddress}');
    // print('?????????????????????????????????????');
    // print('?????????????????????????????????????');
    // print('?????????????????????????????????????');
    // _applyCartAddress(
    //   text: context.read<HomeCubit>().userAddress ?? '',
    //   lat: context.read<HomeCubit>().latUserAddress ?? 0,
    //   lon: context.read<HomeCubit>().lonUserAddress ?? 0,
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillCurrentLocation();
      //_changeLocation(isRTL: context.locale == 'en' ? true : false);
    });
    getAddressFromLatLon(
      lat: context.read<HomeCubit>().latUserAddress ?? 0,
      lon: context.read<HomeCubit>().lonUserAddress ?? 0,
    );
    _tempOrderAddress = OrderAddress(
      text: context.read<HomeCubit>().userAddress ?? '',
      latitude: context.read<HomeCubit>().latUserAddress ?? 0,
      longitude: context.read<HomeCubit>().lonUserAddress ?? 0,
    );
  }

  Future<void> _openRestaurantFromCart(int restaurantId) async {
    if (restaurantId <= 0) return;

    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider(create: (_) => getIt<RatingSubmitCubit>()),
            BlocProvider(create: (_) => getIt<FavoritesCubit>()),
          ],
          child: ResturantDetails(restaurant_id: restaurantId),
        ),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await context.read<CartCubit>().loadCart(silent: false);
    } else {
      context.read<CartCubit>().loadCart(silent: true);
    }
  }

  @override
  void dispose() {
    _tempDetailsCtrl.dispose();
    _tempDetailsFocus.dispose();
    _orderNotesCtrl.dispose();
    super.dispose();
  }

  List<AddressModel> _parseAddresses(dynamic raw) {
    List? listRaw;

    if (raw is List) {
      listRaw = raw;
    } else if (raw is Map) {
      final root = raw.cast<String, dynamic>();
      final d = root["data"];
      final a = root["addresses"];

      if (a is List) listRaw = a;
      if (listRaw == null && d is List) listRaw = d;

      if (listRaw == null && d is Map) {
        final dd = d.cast<String, dynamic>();
        final dda = dd["addresses"];
        if (dda is List) listRaw = dda;
      }
    }

    final list = <AddressModel>[];
    if (listRaw != null) {
      for (final e in listRaw) {
        if (e is Map) {
          list.add(AddressModel.fromJson(e.cast<String, dynamic>()));
        }
      }
    }

    return list;
  }

  Future<void> _applyCartAddress({
    required String text,
    required double lat,
    required double lon,
  }) async {
    print('///////////////////////////');
    print('??????????????????????????????????');
    print('??????????????????????????????????');
    print('$text');
    print('$lon');
    print('$lat');
    print('??????????????????????????????????');
    print('??????????????????????????????????');
    setState(() {
      _tempOrderAddress = OrderAddress(
        text: text,
        latitude: lat,
        longitude: lon,
      );
      _tempDetailsCtrl.text = text;
    });

    await AuthStorageHelper.saveCartLocation(text: text, lat: lat, lon: lon);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tempDetailsFocus.requestFocus();
    });
  }

  Future<void> _onChangeAddressTap({required bool isRTL}) async {
    final colorScheme = Theme.of(context).colorScheme;

    final res = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetColorScheme = Theme.of(ctx).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: AppColor.Dark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).padding.bottom),
          child: SafeArea(
            top: false,
            child: FutureBuilder(
              future: getIt<ProfileRepository>().getAddresses(),
              builder: (context, snap) {
                final data = snap.data;

                final addresses = (data != null && data.ok)
                    ? _parseAddresses(data.data)
                    : const <AddressModel>[];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8.h),
                    Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: sheetColorScheme.onSurface.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isRTL ? "اختر عنوان" : "Choose address",
                              style: TextStyle(
                                color: sheetColorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: Icon(
                              Icons.close,
                              color: sheetColorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppColor.search.withOpacity(0.6)),
                    ListTile(
                      onTap: () => Navigator.pop(ctx, {"kind": "map"}),
                      leading: Icon(
                        Icons.map_outlined,
                        color: AppColor.primaryColor,
                      ),
                      title: Text(
                        isRTL ? "اختيار من الخريطة" : "Pick on map",
                        style: TextStyle(
                          color: sheetColorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: sheetColorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    ListTile(
                      onTap: () => getLatLon(),
                      leading: Icon(
                        Icons.location_on,
                        color: AppColor.primaryColor,
                      ),
                      title: Text(
                        isRTL ? "الموقع الحالي" : "Current Location",
                        style: TextStyle(
                          color: sheetColorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: sheetColorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (snap.connectionState == ConnectionState.waiting)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primaryColor,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              isRTL
                                  ? "جارٍ تحميل العناوين..."
                                  : "Loading addresses...",
                              style: TextStyle(
                                color: sheetColorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (addresses.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        child: Text(
                          isRTL
                              ? "لا يوجد عناوين محفوظة"
                              : "No saved addresses",
                          style: TextStyle(
                            color: sheetColorScheme.onSurface.withOpacity(0.7),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                            left: 6.w,
                            right: 6.w,
                            bottom: 10.h,
                          ),
                          itemCount: addresses.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: sheetColorScheme.outlineVariant.withOpacity(
                              0.35,
                            ),
                          ),
                          itemBuilder: (context, i) {
                            final a = addresses[i];
                            return ListTile(
                              onTap: () => Navigator.pop(ctx, {
                                "kind": "saved",
                                "text": a.address,
                                "lat": a.latitude,
                                "lon": a.longitude,
                              }),
                              leading: Icon(
                                Icons.location_on,
                                color: sheetColorScheme.primary,
                              ),
                              title: Text(
                                a.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: sheetColorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              trailing: a.isDefault
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            sheetColorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        isRTL ? "افتراضي" : "Default",
                                        style: TextStyle(
                                          color: sheetColorScheme
                                              .onPrimaryContainer,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.chevron_right,
                                      color: sheetColorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted || res == null) return;

    final kind = (res["kind"] ?? "").toString();
    if (kind == "map") {
      await _changeLocation(isRTL: isRTL);
      return;
    }

    if (kind == "saved") {
      final text = (res["text"] ?? "").toString().trim();
      final lat = (res["lat"] as num?)?.toDouble() ?? 0.0;
      final lon = (res["lon"] as num?)?.toDouble() ?? 0.0;

      if (text.isEmpty || lat == 0 || lon == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? "تعذر اختيار العنوان" : "Couldn't select address",
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }

      await _applyCartAddress(text: text, lat: lat, lon: lon);
    }
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
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              "cart.recommended_loading".tr(),
              style: TextStyle(
                color: AppColor.white.withOpacity(0.75),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
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
      // decoration: BoxDecoration(
      //   color: colorScheme.surface,
      //   border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      //   borderRadius: BorderRadius.circular(14.r),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "cart.people_also_added".tr(),
            style: TextStyle(
              color: AppColor.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 220.h,
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
                  width: 142.w,
                  child: Container(
                    decoration: BoxDecoration(
                      // color: colorScheme.surface,
                      // borderRadius: BorderRadius.circular(14.r),
                      // border: Border.all(
                      //   color: colorScheme.outline.withOpacity(0.18),
                      // ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  width: 142.w,
                                  height: 142.w,
                                  child: Stack(
                                    children: [
                                      (a.image == null || a.image!.isEmpty)
                                          ? Image.asset(
                                              "assets/images/003.jpg",
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              a.image!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                    "assets/images/003.jpg",
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                            ),
                                      Positioned(
                                        bottom: 5,
                                        right: 5,
                                        child: Row(
                                          children: [
                                            if (qty <= 0)
                                              InkWell(
                                                onTap: disabled
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _appetizerQty[a.id] =
                                                              1;
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
                                                        ? AppColor.Dark
                                                        : AppColor.Dark,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          AppColor
                                                              .Dark.withOpacity(
                                                            0.22,
                                                          ),
                                                    ),
                                                  ),
                                                  child: syncing
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                10.w,
                                                              ),
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: AppColor
                                                                    .primaryColor,
                                                              ),
                                                        )
                                                      : Icon(
                                                          Icons.add,
                                                          // color: disabled ? colorScheme.onSurface.withOpacity(0.35) : colorScheme.primary,
                                                          color: AppColor.white,
                                                        ),
                                                ),
                                              )
                                            else
                                              Container(
                                                height: 38.w,
                                                decoration: BoxDecoration(
                                                  color: AppColor.Dark,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  border: Border.all(
                                                    color: AppColor
                                                        .Dark.withOpacity(0.22),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: disabled
                                                          ? null
                                                          : () {
                                                              final next =
                                                                  (qty - 1)
                                                                      .clamp(
                                                                        0,
                                                                        99,
                                                                      );
                                                              setState(() {
                                                                if (next == 0) {
                                                                  _appetizerQty
                                                                      .remove(
                                                                        a.id,
                                                                      );
                                                                } else {
                                                                  _appetizerQty[a
                                                                          .id] =
                                                                      next;
                                                                }
                                                              });
                                                              _syncAppetizer(
                                                                appetizerId:
                                                                    a.id,
                                                                quantity: next,
                                                              );
                                                            },
                                                      child: SizedBox(
                                                        width: 38.w,
                                                        height: 38.w,
                                                        child: Icon(
                                                          Icons.remove,
                                                          // color: disabled ? colorScheme.onSurface.withOpacity(0.35) : colorScheme.primary,
                                                          color: AppColor.white,
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
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: AppColor
                                                                      .primaryColor,
                                                                ),
                                                              )
                                                            : Text(
                                                                qty.toString(),
                                                                style: TextStyle(
                                                                  color: AppColor
                                                                      .white,
                                                                  fontSize:
                                                                      13.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: disabled
                                                          ? null
                                                          : () {
                                                              final next =
                                                                  (qty + 1)
                                                                      .clamp(
                                                                        0,
                                                                        99,
                                                                      );
                                                              setState(() {
                                                                _appetizerQty[a
                                                                        .id] =
                                                                    next;
                                                              });
                                                              _syncAppetizer(
                                                                appetizerId:
                                                                    a.id,
                                                                quantity: next,
                                                              );
                                                            },
                                                      child: SizedBox(
                                                        width: 38.w,
                                                        height: 38.w,
                                                        child: Icon(
                                                          Icons.add,
                                                          // color: disabled ? colorScheme.onSurface.withOpacity(0.35) : colorScheme.primary,
                                                          color: AppColor.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   top: 8.h,
                              //   left: 8.w,
                              //   child: Container(
                              //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              //     decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8.r)),
                              //     child: Text(
                              //       "cart.popular".tr(),
                              //       style: TextStyle(color: colorScheme.onPrimary, fontSize: 11.sp, fontWeight: FontWeight.w800),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            0.w,
                            0.h,
                            10.w,
                            8.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColor.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 0.h),
                              Text(
                                context.syp(a.price),
                                style: TextStyle(
                                  color: AppColor.white,
                                  fontSize: 12.sp,
                                  // fontWeight: FontWeight.w800
                                ),
                              ),
                              SizedBox(height: 5.h),
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

    print('???????????????????????????????');
    print('???????????????????????????????');
    print('${_tempOrderAddress!.latitude}');
    print('${_tempOrderAddress!.longitude}');
    print('???????????????????????????????');
    print('???????????????????????????????');

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
            backgroundColor: AppColor.Dark,
            title: Text(
              isRTL ? "حذف العنصر؟" : "Delete item?",
              style: TextStyle(color: AppColor.white),
            ),
            content: Text(
              isRTL
                  ? "هل تريد حذف هذا العنصر من السلة؟"
                  : "Do you want to remove this item from cart?",
              style: TextStyle(color: AppColor.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  isRTL ? "إلغاء" : "Cancel",
                  style: TextStyle(color: AppColor.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  isRTL ? "حذف" : "Delete",
                  style: TextStyle(color: AppColor.red),
                ),
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

  ///
  ///
  ///
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
    // if (_orderNotesCtrl.text.isEmpty) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(isRTL ? "ملاحظة الموقع مطلوبة" : "Order note is required "), behavior: SnackBarBehavior.floating));
    //   return;
    // }

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

  ///
  ///
  ///
  // ----------------------------
  // UI
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColor.Dark,
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(60.h),
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: BlocBuilder<CartCubit, CartState>(
      //       builder: (context, state) {
      //         final title = state.maybeWhen(
      //           cartLoaded: (cart, updatingIds, toast, isRefreshing) =>
      //               cart.restaurantName.isNotEmpty ? cart.restaurantName : (isRTL ? "سلّتي" : "My Cart"),
      //           orElse: () => isRTL ? "سلّتي" : "My Cart",
      //         );
      //
      //         return CustomAppbarProfile(
      //           title: title,
      //           icon: Icons.arrow_back_ios,
      //           ontap: () => Navigator.pop(context),
      //           backgroundcolor: Colors.transparent,
      //         );
      //       },
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          // Positioned.fill(
          //   child: Image.asset(
          //     "assets/images/background_auth.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),
          // Positioned.fill(
          //   child: Container(color: colorScheme.surface.withOpacity(0.85)),
          // ),
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
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      ),
                    ),
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
                            vertical: 0.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (toast != null && toast.trim().isNotEmpty)
                                _ToastBox(toast: toast),

                              BlocBuilder<CartCubit, CartState>(
                                builder: (context, state) {
                                  final title = state.maybeWhen(
                                    cartLoaded:
                                        (
                                          cart,
                                          updatingIds,
                                          toast,
                                          isRefreshing,
                                        ) => cart.restaurantName.isNotEmpty
                                        ? cart.restaurantName
                                        : (isRTL ? "سلّتي" : "My Cart"),
                                    orElse: () => isRTL ? "سلّتي" : "My Cart",
                                  );

                                  return Container(
                                    // height: 100.h,
                                    // color: Colors.red,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 0.h),
                                      child: CustomAppbarProfile(
                                        title: title,
                                        icon: Icons.arrow_back_ios,
                                        ontap: () => Navigator.pop(context),
                                        backgroundcolor: Colors.transparent,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10.h),

                              if (cart.items.isEmpty)
                                _EmptyCart(isRTL: isRTL)
                              else
                                _CartItemsSection(
                                  cart: cart,
                                  isRTL: isRTL,
                                  updatingIds: updatingIds,
                                  itemNotes: _itemNotes,
                                  onAddMore: () => _openRestaurantFromCart(
                                    cart.restaurantId,
                                  ),
                                  onEditNote: (it) =>
                                      _editItemNote(isRTL: isRTL, item: it),
                                  onDelete: (it) async {
                                    final ok = await _confirmDelete(
                                      context,
                                      isRTL: isRTL,
                                    );
                                    if (!ok) return;

                                    // Check if there's only one item in the cart
                                    if (cart.items.length == 1) {
                                      // Navigate immediately to home
                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MainShell(),
                                          ),
                                          (route) => false,
                                        );
                                      }

                                      // Remove the item after navigation
                                      context.read<CartCubit>().removeItem(
                                        it.id,
                                      );
                                      setState(() => _itemNotes.remove(it.id));
                                    } else {
                                      // Only remove the specific item
                                      context.read<CartCubit>().removeItem(
                                        it.id,
                                      );
                                      setState(() => _itemNotes.remove(it.id));
                                    }
                                  },
                                  onQtyChange: (it, newQty) {
                                    context.read<CartCubit>().updateQty(
                                      cartItemId: it.id,
                                      quantity: newQty,
                                    );
                                  },
                                ),

                              SizedBox(height: 5.h),
                              Divider(
                                height: 1,
                                thickness: 0.5.w,
                                color: AppColor.search,
                              ),
                              _recommendedAppetizersSection(
                                isRTL: isRTL,
                                cart: cart,
                              ),

                              if (_appetizers.isNotEmpty) ...[
                                // SizedBox(height: 10.h),
                                Divider(
                                  height: 1,
                                  thickness: 0.5.w,
                                  color: AppColor.search,
                                ),
                              ],

                              if (_deliveryType == "delivery") ...[
                                ///
                                /// 34.8795309
                                ///
                                /// //////////////
                                /// 35.9011717
                                AddressSection(
                                  isRTL: isRTL,
                                  address: _tempOrderAddress,
                                  onChangeTap: () =>
                                      _onChangeAddressTap(isRTL: isRTL),
                                  onMapTap: () async =>
                                      await _changeLocation(isRTL: isRTL),
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
                                // SizedBox(height: 10.h),
                                // Divider(),
                              ],
                              // SizedBox(height: 10.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Padding(
                                    //   padding: EdgeInsetsDirectional.only(start: 20.w),
                                    //   child: Text(
                                    //     'cart.order_note'.tr(),
                                    //     style: TextStyle(color: AppColor.white, fontSize: 12.sp),
                                    //   ),
                                    // ),
                                    _OrderNotesSection(
                                      ctrl: _orderNotesCtrl,
                                      isRTL: isRTL,
                                    ),
                                  ],
                                ),
                              ),

                              // VIP Section
                              if (cart.vip != null)
                                Column(
                                  children: [
                                    // Divider(height: 1.w, thickness: 0.7.w),
                                    SizedBox(height: 25.h),
                                    _VipSection(
                                      vip: cart.vip!,
                                      isVipEnabled: _isVipEnabled,
                                      onToggleVip: (enabled) {
                                        setState(() {
                                          _isVipEnabled = enabled;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                              // Divider(height: 1.w, thickness: 0.7.w),
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 12.w,
                                  top: 13.h,
                                ),
                                child: Text(
                                  isRTL ? " تفاصيل الدفع" : "Payment Detail",
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),

                              _TotalsSection(
                                cart: cart,
                                isVipEnabled: _isVipEnabled,
                              ),

                              // SizedBox(height: 10.h),
                              // _OrderNotesSection(ctrl: _orderNotesCtrl, isRTL: isRTL),
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

  final VoidCallback onAddMore;

  final void Function(CartItem it) onEditNote;
  final void Function(CartItem it) onDelete;
  final void Function(CartItem it, int newQty) onQtyChange;

  const _CartItemsSection({
    required this.cart,
    required this.isRTL,
    required this.updatingIds,
    required this.itemNotes,
    required this.onAddMore,
    required this.onEditNote,
    required this.onDelete,
    required this.onQtyChange,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final children = <Widget>[];

    for (final it in cart.items) {
      final isUpdating = updatingIds.contains(it.id);

      final title = isRTL
          ? (it.nameAr.trim().isNotEmpty ? it.nameAr : it.nameEn)
          : (it.nameEn.trim().isNotEmpty ? it.nameEn : it.nameAr);

      final note = (it.specialNotes ?? "").trim();

      children.add(
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: 12.h, start: 0.w),
          child: Slidable(
            key: ValueKey("cart_item_${it.id}"),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.22,
              children: [
                SlidableAction(
                  onPressed: isUpdating ? null : (_) => onDelete(it),
                  backgroundColor: AppColor.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: isRTL ? "حذف" : "Delete",
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                // color: colorScheme.surface,
                // border: Border.all(
                //   color: colorScheme.outline.withOpacity(0.25),
                // ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 8.w),
                    child: MealCard(
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
                  ),
                  if (it != cart.items.last) SizedBox(height: 10.h),

                  if (it != cart.items.last)
                    Divider(
                      height: 1,
                      thickness: 0.5.w,
                      color: AppColor.search,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (cart.items.isNotEmpty) {
      children.add(
        Column(
          children: [
            // Divider(height: 1, thickness: 0.5.w, color: AppColor.search),
            Divider(height: 1, thickness: 0.5.w, color: AppColor.search),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // color: colorScheme.surface,
                // border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
              ),
              child: InkWell(
                onTap: onAddMore,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: AppColor.primaryColor,
                        size: 24.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        isRTL ? "أضف المزيد" : "Add more",
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(children: children);
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
        // color: colorScheme.surface,
        borderRadius: BorderRadius.circular(11.r),
        // border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          _totalLine(
            title: isRTL ? "طريقة الدفع" : "payment method",
            value: cart.itemsTotalAfter,
            before: cart.itemsTotalBefore,
            paymentMethod: isRTL ? "دفع نقدي" : "Cash",
            money: (n) => context.syp(n),
            context: context,
          ),
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
            child: Divider(height: 1, thickness: 0.5.w, color: AppColor.search),
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
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        // color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        // border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: 1,
        style: TextStyle(color: AppColor.white, fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: isRTL ? "ملاحظات الموقع" : "Location notes  ",
          hintStyle: TextStyle(
            color: AppColor.white.withOpacity(0.6),
            fontSize: 12.sp,
          ),
          filled: true,
          fillColor: AppColor.search,
          contentPadding: EdgeInsetsDirectional.only(start: 12.w),

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
        // color: isVipEnabled
        //     ? colorScheme.primary.withOpacity(0.1)
        //     : colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.search),
      ),
      child: InkWell(
        onTap: () => _showVipPopup(context, isVipEnabled),
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
                      color: AppColor.white,
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
                      color: AppColor.white.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isVipEnabled ? AppColor.primaryColor : AppColor.search,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                isVipEnabled
                    ? (isRTL ? "مفعل" : "Enabled")
                    : (isRTL ? "تفعيل" : "Enable"),
                style: TextStyle(
                  color: isVipEnabled
                      ? AppColor.white
                      : AppColor.white.withOpacity(0.8),
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

  void _showVipPopup(BuildContext context, bool enabled) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
        contentPadding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
        backgroundColor: AppColor.Dark,
        title: SizedBox(
          width: w * 0.92,
          child: Text(
            isRTL ? "خدمة VIP" : "VIP Service",
            style: TextStyle(color: AppColor.white),
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
            child: Text(
              isRTL ? "إلغاء" : "Cancel",
              style: TextStyle(color: AppColor.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onToggleVip(!isVipEnabled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isVipEnabled
                  ? AppColor.red
                  : AppColor.primaryColor,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
              isVipEnabled
                  ? (isRTL ? "إلغاء التفعيل" : "Disable")
                  : (isRTL ? "تفعيل" : "Enable"),
              style: TextStyle(color: Colors.white),
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
  String? paymentMethod,

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
              color: isTotal ? AppColor.white : AppColor.white.withOpacity(0.8),
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        if (hasBefore) ...[
          Text(
            money(before!),

            style: TextStyle(
              color: AppColor.white.withOpacity(0.7),
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColor.white.withOpacity(0.7),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Text(
          paymentMethod ?? money(value),
          style: TextStyle(
            color: isTotal
                ? AppColor.white
                : hasBefore
                ? AppColor.red
                : AppColor.white,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

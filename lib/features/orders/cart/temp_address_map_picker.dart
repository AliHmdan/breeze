import 'dart:developer';
import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_helper.dart';

class TempAddressMapPicker extends StatefulWidget {
  final bool isRTL;
  final LatLng? initial;

  const TempAddressMapPicker({super.key, required this.isRTL, this.initial});

  @override
  State<TempAddressMapPicker> createState() => _TempAddressMapPickerState();
}

class _TempAddressMapPickerState extends State<TempAddressMapPicker> {
  GoogleMapController? _map;
  late LatLng _picked;

  bool _locating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('???????????????????????????????');
    print('???????????????????????????????');
    print('${widget.initial!.latitude}');
    print('${widget.initial!.longitude}');
    print('???????????????????????????????');
    print('???????????????????????????????');
    _picked = widget.initial ?? const LatLng(33.5138, 36.2765);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromCurrentLocation();
    });
  }

  Future<void> _initFromCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });

    try {
      // final pos = await LocationHelper.getCurrentPosition();
      if (!mounted) return;

      final current = LatLng(widget.initial!.latitude, widget.initial!.longitude);
      setState(() {
        _picked = current;
        _locating = false;
      });

      await _map?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: current, zoom: 16)));
    } catch (e, st) {
      log("TempAddressMapPicker location error: $e\n$st");
      if (!mounted) return;

      setState(() {
        _locating = false;
        _error = widget.isRTL ? "تعذر تحديد موقعك الحالي، اختره يدويًا" : "Couldn't get your current location. Pick it manually.";
      });
    }
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.isRTL;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    _MapCircleButton(icon: Icons.arrow_back_ios_new, onTap: () => Navigator.pop(context, null)),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(color: colorScheme.surface.withOpacity(0.85), borderRadius: BorderRadius.circular(20.r)),
                        child: Text(
                          isRTL ? "اختيار موقع" : "Pick location",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 13.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(target: _picked, zoom: 16),
            onMapCreated: (c) => _map = c,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            onCameraMove: (pos) => _picked = pos.target,
            markers: {Marker(markerId: const MarkerId("picked"), position: _picked)},
          ),
          Center(
            child: IgnorePointer(child: Icon(Icons.location_pin, size: 46, color: AppColor.primaryColor)),
          ),
          if (_error != null)
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 70.h,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colorScheme.error.withOpacity(0.4)),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          if (_locating)
            Positioned.fill(
              child: Container(
                color: colorScheme.surface.withOpacity(0.25),
                child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
              ),
            ),
          PositionedDirectional(
            top: 40.h,
            start: 24.w,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.7)),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10.w),
                    Icon(Icons.arrow_back_ios, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),

          // Positioned(
          //   bottom: 100.h, // فوق زر التأكيد
          //   right: isRTL ? null : 16.w,
          //   left: isRTL ? 16.w : null,
          //   child: _MapFloatingButton(icon: Icons.my_location, label: isRTL ? "موقعي" : "My location", onTap: _initFromCurrentLocation),
          // ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 42.h,
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: _locating
                    ? null
                    : () async {
                        final fallback = isRTL ? "موقعي الحالي" : "My current location";

                        final text = await LocationHelper.reverseGeocodeText(lat: _picked.latitude, lng: _picked.longitude, fallback: fallback);

                        Navigator.pop(context, {"lat": _picked.latitude, "lng": _picked.longitude, "text": text});
                      },
                child: Text(isRTL ? "تأكيد الموقع" : "Confirm location", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(color: colorScheme.surface.withOpacity(0.85), shape: BoxShape.circle),
        child: Icon(icon, color: colorScheme.onSurface, size: 20.sp),
      ),
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MapFloatingButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onSurface, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

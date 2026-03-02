import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breezefood/features/orders/model/store_order_request.dart';
import 'mini_map_preview.dart';

class AddressSection extends StatelessWidget {
  final bool isRTL;
  final OrderAddress? address;
  final VoidCallback onChangeTap;

  final TextEditingController detailsCtrl;
  final FocusNode detailsFocus;
  final ValueChanged<String> onDetailsChanged;

  const AddressSection({
    super.key,
    required this.isRTL,
    required this.address,
    required this.onChangeTap,
    required this.detailsCtrl,
    required this.detailsFocus,
    required this.onDetailsChanged,
  });

  bool get _hasCoords =>
      address != null && address!.latitude != 0 && address!.longitude != 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      // decoration: BoxDecoration(
      //   color: colorScheme.surface,
      //   borderRadius: BorderRadius.circular(12.r),
      //   border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
      // ),
      child: InkWell(
        onTap: onChangeTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.location_on, color: colorScheme.primary),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      isRTL ? "موقع الاستلام" : "Delivery location",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isRTL ? "تغيير" : "Change",
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.8),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_hasCoords) ...[
                SizedBox(height: 10.h),
                MiniMapPreview(
                  key: ValueKey("${address!.latitude}_${address!.longitude}"),
                  lat: address!.latitude,
                  lng: address!.longitude,
                  onTap: onChangeTap,
                ),
              ],

              SizedBox(height: 10.h),

              // النص
              SizedBox(
                height: 44,
                child: TextField(
                  controller: detailsCtrl,
                  focusNode: detailsFocus,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                  onChanged: onDetailsChanged,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    hintText: isRTL
                        ? "تفاصيل العنوان: بناية، طابق، شقة..."
                        : "Address details: building, floor, apt...",
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

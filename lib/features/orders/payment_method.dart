import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/dialogs.dart' show AppDialog;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// موديل بسيط لتمثيل طريقة دفع
class PaymentMethod {
  final String id;
  final String title;

  /// يمكن تمرير ويدجت جاهزة كأيقونة
  final Widget? trailingIcon;

  /// أو تمرير مسار صورة PNG
  final String? imageAsset;
  final double imageWidth;
  final double imageHeight;
  final BoxFit fit;

  const PaymentMethod({
    required this.id,
    required this.title,
    this.trailingIcon,
    this.imageAsset,
    this.imageWidth = 40,
    this.imageHeight = 24,
    this.fit = BoxFit.contain,
  }) : assert(trailingIcon != null || imageAsset != null, 'PaymentMethod يحتاج إما trailingIcon أو imageAsset');
}

/// ويدجت اختيار طريقة الدفع + زر الطلب
class PaymentMethodSection extends StatefulWidget {
  final String headerTitle;
  final String amountText; // مثل: 5.00$
  final List<PaymentMethod> methods;
  final String? initialSelectedId;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onOrder; // بدل VoidCallback?

  // ألوان قابلة للتخصيص عند الحاجة
  final Color? tileColor;
  final Color radioActive;
  Color? radioInactive = AppColor.white;
  final Color headerColor;
  final Color amountColor;
  final Color orderBtnColor;
  final Color orderTextColor;

  PaymentMethodSection({
    super.key,
    this.headerTitle = "Payment method",
    required this.amountText,
    required this.methods,
    this.initialSelectedId,
    this.onChanged,
    this.onOrder,
    this.tileColor,
    this.radioActive = AppColor.primaryColor,
    this.radioInactive,
    this.headerColor = Colors.white,
    this.amountColor = AppColor.yellow,
    this.orderBtnColor = AppColor.primaryColor,
    this.orderTextColor = Colors.white,
  });

  @override
  State<PaymentMethodSection> createState() => _PaymentMethodSectionState();
}

class _PaymentMethodSectionState extends State<PaymentMethodSection> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId ?? (widget.methods.isNotEmpty ? widget.methods.first.id : "");
  }

  @override
  Widget build(BuildContext context) {
    final radius = 12.r;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          // Padding(
          //   padding: EdgeInsets.only(bottom: 8.h, left: 2.w, right: 2.w),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Text(
          //           widget.headerTitle,
          //           style: TextStyle(
          //             color: widget.headerColor,
          //             fontWeight: FontWeight.w700,
          //             fontSize: 14.sp,
          //           ),
          //         ),
          //       ),
          //       Text(
          //         widget.amountText,
          //         style: TextStyle(
          //           color: widget.amountColor,
          //           fontWeight: FontWeight.w800,
          //           fontSize: 14.sp,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // قائمة طرق الدفع
          /// ////////////////////////////////////////////
          // if (widget.methods.isEmpty)
          //   Padding(
          //     padding: EdgeInsets.symmetric(vertical: 8.h),
          //     child: Text(
          //       'No payment methods',
          //       style: TextStyle(color: AppColor.light, fontSize: 12.sp),
          //     ),
          //   )
          // else
          //   ...widget.methods.map((m) {
          //     final selected = _selectedId == m.id;
          //     return _PaymentTile(
          //       method: m,
          //       selected: selected,
          //       onTap: () {
          //         if (!selected) {
          //           setState(() => _selectedId = m.id);
          //           widget.onChanged?.call(m.id);
          //         }
          //       },
          //       radius: radius,
          //       tileColor: widget.tileColor ?? Theme.of(context).colorScheme.surface,
          //       radioActive: widget.radioActive,
          //       radioInactive: widget.radioInactive ??= AppColor.white,
          //     );
          //   }),
          //
          // SizedBox(height: 10.h),

          // زر الطلب
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () => widget.onOrder?.call(_selectedId),
              // onPressed: () async {
              //   await AppDialog.showSuccessDialog(
              //     title: context.locale == 'en' ? "تم إرسال الطلب بنجاح" : "Order placed successfully",
              //     message: context.locale == 'en' ? "رقم الطلب: #1\nالحالة: fss" : "Order ID: #sadass\nStatus: sadasd",
              //   );
              // },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.orderBtnColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
              child: Text(
                "orders.Order".tr(),
                style: TextStyle(color: widget.orderTextColor, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة دفع مفردة
class _PaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback? onTap;
  final double radius;
  final Color tileColor;
  final Color radioActive;
  final Color radioInactive;

  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
    required this.radius,
    required this.tileColor,
    required this.radioActive,
    required this.radioInactive,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetW = (method.imageWidth.w * dpr).round(); // حجم فعلي مناسب للجهاز
    final targetH = (method.imageHeight.h * dpr).round();

    final Widget trailing =
        method.trailingIcon ??
        (method.imageAsset != null
            ? RepaintBoundary(
                child: Image(
                  image: ResizeImage(
                    AssetImage(method.imageAsset!), // ← downsample داخل الكاش
                    width: targetW,
                    height: targetH,
                  ),
                  width: method.imageWidth.w,
                  height: method.imageHeight.h,
                  fit: method.fit,
                  filterQuality: FilterQuality.low, // أخف على المعالج
                  gaplessPlayback: true,
                ),
              )
            : const SizedBox());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        // color: tileColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              _RadioVisual(activeColor: radioActive, inactiveColor: radioInactive, selected: selected),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  method.title,
                  style: TextStyle(color: AppColor.light, fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// راديو بصري أنيق
class _RadioVisual extends StatelessWidget {
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;

  const _RadioVisual({required this.selected, required this.activeColor, required this.inactiveColor});

  @override
  Widget build(BuildContext context) {
    final outerSize = 22.r;
    final innerSize = 12.r;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? activeColor : inactiveColor, width: 2),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: selected ? innerSize : 0,
        height: selected ? innerSize : 0,
        decoration: BoxDecoration(color: selected ? activeColor : Colors.transparent, shape: BoxShape.circle),
      ),
    );
  }
}

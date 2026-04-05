import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order_sheet/notes_field.dart';
import 'package:breezefood/features/orders/request_order/counter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

Future<SupermarketAddToCartResult?> showSupermarketAddOrderDialog(
  BuildContext context, {
  required String title,
  required num price,
  num? oldPrice,
  required String imagePath,
}) async {
  return showModalBottomSheet<SupermarketAddToCartResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    builder: (_) {
      final height = MediaQuery.of(context).size.height * 0.9;

      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColor.Dark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SupermarketAddOrderBody(title: title, price: price, oldPrice: oldPrice, imagePath: imagePath),
      );
    },
  );
}

class SupermarketAddOrderBody extends StatefulWidget {
  final String title;
  final num price;
  final String imagePath;
  final num? oldPrice;

  const SupermarketAddOrderBody({super.key, required this.title, required this.price, required this.imagePath, this.oldPrice});

  @override
  State<SupermarketAddOrderBody> createState() => _SupermarketAddOrderBodyState();
}

class _SupermarketAddOrderBodyState extends State<SupermarketAddOrderBody> {
  int _qty = 1;
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  final TextEditingController _noteCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final num pricePerItem = widget.price;

    return Column(
      children: [
        // SizedBox(height: 10.h),
        // Container(
        //   width: 40.w,
        //   height: 4.h,
        //   decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
        // ),
        // SizedBox(height: 8.h),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE + close
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                      child: (widget.imagePath.startsWith("http://") || widget.imagePath.startsWith("https://"))
                          ? Image.network(
                              widget.imagePath,
                              width: double.infinity,
                              height: 400.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Image.asset("assets/images/bread.png", width: double.infinity, height: 200.h, fit: BoxFit.cover),
                            )
                          : Image.asset(widget.imagePath, width: double.infinity, height: 200.h, fit: BoxFit.cover),
                    ),
                    // Fixed close button overlay
                    PositionedDirectional(
                      top: 5,
                      end: 1,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.black54),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          minimumSize: WidgetStateProperty.all(const Size(30, 30)),
                          fixedSize: WidgetStateProperty.all(const Size(30, 30)),
                        ),
                      ),
                    ),
                    // PositionedDirectional(
                    //   top: 10.h,
                    //   end: 10.w,
                    //   child: IconButton(
                    //     onPressed: () => Navigator.pop(context),
                    //     icon: const Icon(Icons.close, color: Colors.white),
                    //     style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.black54)),
                    //   ),
                    // ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title.isEmpty ? "Empty" : widget.title,

                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 22.sp,
                          fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      ///
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: CustomSubTitle(subtitle: widget.title, color: AppColor.white, fontsize: 16),
                      //     ),
                      //
                      //     if (widget.oldPrice != null) ...[
                      //       Text(
                      //         context.syp(widget.oldPrice!, decimals: 0),
                      //         style: TextStyle(color: Colors.redAccent, fontSize: 12.sp, decoration: TextDecoration.lineThrough),
                      //       ),
                      //       SizedBox(width: 8.w),
                      //     ],
                      //
                      //     Text(
                      //       context.money(widget.price, decimals: 0),
                      //       style: TextStyle(color: AppColor.yellow, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),

                      // SizedBox(height: 14.h),
                      ///
                      // CustomSubTitle(subtitle: "supermarket.quantity".tr(), color: AppColor.white, fontsize: 14.sp),
                      // SizedBox(height: 10.h),
                      ///
                      QtyCounter(value: _qty, onChanged: (v) => setState(() => _qty = v), pricePerItem: pricePerItem, moneyDecimals: 0),

                      SizedBox(height: 16.h),

                      CustomSubTitle(subtitle: "supermarket.notes_optional".tr(), color: AppColor.white, fontsize: 14.sp),
                      SizedBox(height: 6.h),
                      // NotesField(controller: notesController),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        showCursor: true,
                        cursorColor: AppColor.white,
                        cursorWidth: 2,
                        cursorRadius: const Radius.circular(2),
                        style: TextStyle(color: AppColor.white, fontSize: 14.sp),
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          hintText: "supermarket.notes_hint".tr(),
                          hintStyle: TextStyle(color: AppColor.LightActive, fontSize: 12.sp),

                          isDense: true,
                          contentPadding: EdgeInsets.zero,

                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF373737), width: 1)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF373737), width: 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ADD BUTTON
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
              onPressed: () {
                Navigator.pop(context, SupermarketAddToCartResult(quantity: _qty, notes: notesController.text.trim()));
              },
              child: Text(
                "supermarket.add_to_cart_with_total".tr(namedArgs: {"total": context.money(pricePerItem * _qty, decimals: 0)}),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SupermarketAddToCartResult {
  final int quantity;
  final String notes;

  const SupermarketAddToCartResult({required this.quantity, required this.notes});
}

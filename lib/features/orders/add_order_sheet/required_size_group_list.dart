import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequiredSizeGroupList extends StatelessWidget {
  final ExtraGrouped group;
  final int? selectedExtraId;
  final ValueChanged<int?> onSelect;
  final bool highlightRequired;

  const RequiredSizeGroupList({
    super.key,
    required this.group,
    required this.selectedExtraId,
    required this.onSelect,
    required this.highlightRequired,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    String title() {
      final t = isRTL ? (group.nameAr ?? "") : (group.nameEn ?? "");
      return t.trim().isEmpty ? (isRTL ? "الحجم" : "Size") : t;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        CustomSubTitle(subtitle: title(), color: AppColor.white, fontsize: 17),

        SizedBox(height: 8.h),

        /// ITEMS
        ...group.items.map((it) {
          final name = isRTL ? it.nameAr : it.nameEn;

          final isSelected = selectedExtraId == it.id;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.vibrate();

                if (isSelected) {
                  onSelect(null);
                } else {
                  onSelect(it.id);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          activeColor: AppColor.primaryColor,
                          side: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColor.gry
                                : const Color(0xFF262626),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          value: isSelected,
                          onChanged: (_) {
                            HapticFeedback.vibrate();

                            if (isSelected) {
                              onSelect(null);
                            } else {
                              onSelect(it.id);
                            }
                          },
                        ),

                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF262626),

                              //   color: Color(0xFF2D2D2D)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    context.syp(it.price),
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily:
                          Localizations.localeOf(context).languageCode == 'ar'
                          ? 'Cairo'
                          : 'Inter',
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Color(0xFF373737),
                    ),
                  ),
                  // CustomSubTitle(
                  //   subtitle:
                  //   context.money(it.price),
                  //   color: AppColor.LightActive,
                  //   fontsize: 12,
                  // ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

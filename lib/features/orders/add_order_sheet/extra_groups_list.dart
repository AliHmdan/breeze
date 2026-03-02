import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExtraGroupsList extends StatelessWidget {
  final List<ExtraGrouped> groups;

  /// groupId -> extraId (nullable للسماح بإلغاء التحديد)
  final Map<int, int?> selectedChoice;

  final void Function(int groupId, int? extraId) onChanged;

  const ExtraGroupsList({
    super.key,
    required this.groups,
    required this.selectedChoice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    String groupTitle(ExtraGrouped g) {
      final t = isRTL ? (g.nameAr ?? "") : (g.nameEn ?? "");
      return t.trim().isEmpty ? (isRTL ? "إضافات" : "Extras") : t;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((g) {
        final title = groupTitle(g);
        final chosenId = selectedChoice[g.groupId];

        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// GROUP TITLE
              CustomSubTitle(
                subtitle: title,
                color: AppColor.white,
                fontsize: 16,
              ),

              SizedBox(height: 8.h),

              ...g.items.map((it) {
                final name = isRTL ? it.nameAr : it.nameEn;

                final isSelected = chosenId == it.id;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
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
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColor.gry
                                    : const Color(0xFF262626),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              value: isSelected,
                              onChanged: (val) {
                                if (val == true) {
                                  onChanged(g.groupId, it.id);
                                } else {
                                  onChanged(g.groupId, null);
                                }
                              },
                            ),

                            // SizedBox(width: 2.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    onChanged(g.groupId, null);
                                  } else {
                                    onChanged(g.groupId, it.id);
                                  }
                                },
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
                                  ),
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
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Color(0xFF373737),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}

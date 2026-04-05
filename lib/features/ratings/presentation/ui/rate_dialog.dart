import 'package:breezefood/core/component/color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RateDialogResult {
  final double? rating;
  final bool delete;
  const RateDialogResult.submit(this.rating) : delete = false;
  const RateDialogResult.delete() : rating = null, delete = true;
}

class RateDialog extends StatefulWidget {
  final double currentRating;
  final int? reviewId;
  final bool allowEditWhenReviewed;

  const RateDialog({super.key, required this.currentRating, required this.reviewId, this.allowEditWhenReviewed = false});

  bool get hasReview => reviewId != null && (reviewId ?? 0) > 0;

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  late double selectedRate;

  @override
  void initState() {
    super.initState();
    selectedRate = widget.currentRating <= 0 ? 1.0 : widget.currentRating;
  }

  @override
  Widget build(BuildContext context) {
    final hasReview = widget.hasReview;

    // ✅ إذا المستخدم مقيّم: لا تعديل ولا submit (حسب طلبك)
    final readOnly = hasReview && widget.allowEditWhenReviewed == false;

    return Dialog(
      // backgroundColor: Colors.black87,
      backgroundColor: AppColor.Dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColor.white),
              ),
            ),
            SizedBox(height: 10.h),

            Text(
              hasReview
                  ? "reviews.your_rate_title"
                        .tr() // ضيفها بالترجمة
                  : "reviews.rate_title".tr(),
              style: TextStyle(color: AppColor.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 15.h),

            AbsorbPointer(
              absorbing: readOnly, // ✅ يمنع التعديل
              child: Opacity(
                opacity: readOnly ? 0.9 : 1.0,
                child: RatingBar.builder(
                  initialRating: selectedRate,
                  minRating: 1,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 35,
                  unratedColor: Colors.white30,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) => setState(() => selectedRate = rating),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              selectedRate.toStringAsFixed(1),
              style: TextStyle(color: AppColor.white, fontSize: 14.sp),
            ),

            SizedBox(height: 10.h),

            Text(
              hasReview ? "reviews.already_rated_hint".tr() : "reviews.rate_hint".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.white.withOpacity(0.7), fontSize: 12.sp),
            ),

            SizedBox(height: 20.h),

            if (!hasReview) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: () {
                    Navigator.pop(context, RateDialogResult.submit(selectedRate));
                  },
                  child: Text(
                    "reviews.submit".tr(),
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ),
            ],

            if (hasReview) ...[
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    final ok = await _confirmDelete(context);
                    if (ok != true) return;
                    Navigator.pop(context, const RateDialogResult.delete());
                  },
                  child: Text(
                    "reviews.delete".tr(),
                    style: TextStyle(color: AppColor.red, fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: Text("reviews.delete_confirm_title".tr(), style: const TextStyle(color: Colors.white)),
        content: Text("reviews.delete_confirm_body".tr(), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("reviews.delete_confirm_no".tr())),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("reviews.delete_confirm_yes".tr(), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

Future<RateDialogResult?> showRateDialog(BuildContext context, {required double currentRating, required int? reviewId}) {
  return showDialog<RateDialogResult>(
    context: context,
    barrierDismissible: true,
    builder: (_) => RateDialog(
      currentRating: currentRating,
      reviewId: reviewId,
      allowEditWhenReviewed: false, // ✅ حسب طلبك
    ),
  );
}

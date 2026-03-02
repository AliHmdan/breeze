import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupermarketInfoWidget extends StatefulWidget {
  final String supermarketName;
  final int marketId; // Added marketId for persistence
  final double ratingAvg;
  final int ratingCount;
  final double deliveryBaseFee;
  final double deliveryFinalFee;
  final int deliveryTime;
  final VoidCallback? onRateTap;
  final VoidCallback? onSearch;

  const SupermarketInfoWidget({
    super.key,
    required this.supermarketName,
    required this.marketId,
    required this.ratingAvg,
    required this.ratingCount,
    required this.deliveryBaseFee,
    required this.deliveryFinalFee,
    required this.deliveryTime,
    this.onRateTap,
    this.onSearch,
  });

  @override
  State<SupermarketInfoWidget> createState() => _SupermarketInfoWidgetState();
}

class _SupermarketInfoWidgetState extends State<SupermarketInfoWidget> {
  double _currentRating = 0.0;
  bool _hasUserRated = false;

  @override
  void initState() {
    super.initState();
    _loadSavedRating();
  }

  void _loadSavedRating() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRating = prefs.getDouble('rating_${widget.marketId}') ?? 0.0;
      final hasRated = prefs.getBool('hasRated_${widget.marketId}') ?? false;

      setState(() {
        _currentRating = savedRating;
        _hasUserRated = hasRated;
      });

      print('Loaded saved rating for ${widget.supermarketName}: $savedRating');
    } catch (e) {
      print('Error loading saved rating: $e');
    }
  }

  Future<void> _saveRatingToStorage(double rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('rating_${widget.marketId}', rating);
      await prefs.setBool('hasRated_${widget.marketId}', true);
      print('Saved rating to storage for ${widget.supermarketName}: $rating');
    } catch (e) {
      print('Error saving rating to storage: $e');
    }
  }

  Future<void> _deleteRatingFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rating_${widget.marketId}');
      await prefs.remove('hasRated_${widget.marketId}');
      print('Deleted rating from storage for ${widget.supermarketName}');
    } catch (e) {
      print('Error deleting rating from storage: $e');
    }
  }

  bool get showTwoPrices => widget.deliveryBaseFee != widget.deliveryFinalFee;

  @override
  Widget build(BuildContext context) {
    final deliveryTimeText = widget.deliveryTime > 0
        ? "${widget.deliveryTime} ${"common.min".tr()}"
        : "--";
    final deliveryBaseText = context.syp(widget.deliveryBaseFee, decimals: 0);
    final deliveryFinalText = context.syp(widget.deliveryFinalFee, decimals: 0);

    // Use the saved rating if user has rated, otherwise use the original rating
    final displayRating = _hasUserRated ? _currentRating : widget.ratingAvg;
    final avgRatingText = displayRating > 0.0
        ? displayRating.toStringAsFixed(1)
        : "0.0";
    final reviewsCountText = "${widget.ratingCount}";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColor.Dark,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            // Rating Section
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onRateTap ?? () => _showRatingDialog(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4.w),
                        Text(
                          avgRatingText,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 11.5.sp,
                            fontFamily: context.isAr ? 'Cairo' : 'Inter',
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "($reviewsCountText)",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: context.isAr ? 'Cairo' : 'Inter',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "restaurant.rate_us".tr(),
                      style: TextStyle(
                        color: AppColor.gryLighter,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDivider(),

            // Delivery Section
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 9.h),
                  Image.asset(
                    "assets/icons/new_del.png",
                    width: 20.w,
                    height: 20.h,
                    color: AppColor.white,
                  ),
                  SizedBox(height: 12.h),
                  if (showTwoPrices) ...[
                    Text(
                      deliveryBaseText,
                      style: TextStyle(
                        color: AppColor.LightActive,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      deliveryFinalText,
                      style: TextStyle(
                        color: AppColor.red,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),
                  ] else
                    Text(
                      deliveryFinalText,
                      style: TextStyle(
                        color: AppColor.gryLighter,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),
                ],
              ),
            ),
            _buildDivider(),

            // Time Section
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 10.h),
                  Image.asset(
                    "assets/icons/clock_new.png",
                    width: 17.w,
                    height: 17.h,
                    color: AppColor.white,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    deliveryTimeText,
                    style: TextStyle(
                      color: AppColor.gryLighter,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: context.isAr ? 'Cairo' : 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 0.5,
      height: 25.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColor.LightActive,
    );
  }

  void _showRatingDialog(BuildContext context) {
    double selectedRating = _hasUserRated
        ? _currentRating
        : 3.0; // Use saved rating or default
    bool showDeleteDialog = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (showDeleteDialog) {
              // Delete confirmation dialog
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 50.h,
                  ),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColor.Dark,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Delete Rating'.tr(),
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: context.isAr ? 'Cairo' : 'Inter',
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        'Are you sure you want to delete your rating?'.tr(),
                        style: TextStyle(
                          color: AppColor.white.withOpacity(0.8),
                          fontSize: 14.sp,
                          fontFamily: context.isAr ? 'Cairo' : 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 30.h),

                      Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: SizedBox(
                              height: 45.h,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel'.tr(),
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: context.isAr
                                        ? 'Cairo'
                                        : 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          // Delete Button
                          Expanded(
                            child: SizedBox(
                              height: 45.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  _deleteRating();
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Delete'.tr(),
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: context.isAr
                                        ? 'Cairo'
                                        : 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            // Main rating dialog
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColor.Dark,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rate ${widget.supermarketName}',
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: context.isAr ? 'Cairo' : 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close,
                            color: AppColor.white.withOpacity(0.7),
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    // Rating Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = (index + 1).toDouble();
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Icon(
                              Icons.star,
                              size: 40.sp,
                              color: index < selectedRating
                                  ? Colors.amber
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 15.h),

                    // Rating Value
                    Text(
                      '$selectedRating',
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      'Tap to rate'.tr(),
                      style: TextStyle(
                        color: AppColor.white.withOpacity(0.6),
                        fontSize: 14.sp,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Delete Rating Option
                    if (_hasUserRated)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showDeleteDialog = true;
                          });
                        },
                        child: Text(
                          'Delete your rating'.tr(),
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: context.isAr ? 'Cairo' : 'Inter',
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                    SizedBox(height: _hasUserRated ? 20.h : 30.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Save the rating
                          _saveRating(selectedRating);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Submit Rating'.tr(),
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: context.isAr ? 'Cairo' : 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveRating(double rating) async {
    // Update the current rating state and mark as user rated
    setState(() {
      _currentRating = rating;
      _hasUserRated = true;
    });

    // Save to persistent storage
    await _saveRatingToStorage(rating);

    // TODO: Implement actual rating saving logic
    // This should connect to your backend API to save the rating
    EasyLoading.showSuccess('Rating saved: ${rating.toStringAsFixed(1)} stars');
    print(
      'Rating saved for ${widget.supermarketName}: ${rating.toStringAsFixed(1)} stars',
    );

    // Here you would typically make an API call to save the rating
    // Example:
    // await apiService.saveRating(
    //   marketId: widget.marketId,
    //   rating: rating,
    // );
  }

  void _deleteRating() async {
    // Reset the current rating state and mark as not rated
    setState(() {
      _currentRating = 0.0;
      _hasUserRated = false;
    });

    // Delete from persistent storage
    await _deleteRatingFromStorage();

    // TODO: Implement actual rating deletion logic
    // This should connect to your backend API to delete the rating
    EasyLoading.showSuccess('Rating deleted');
    print('Rating deleted for ${widget.supermarketName}');

    // Here you would typically make an API call to delete the rating
    // Example:
    // await apiService.deleteRating(
    //   marketId: widget.marketId,
    // );
  }
}

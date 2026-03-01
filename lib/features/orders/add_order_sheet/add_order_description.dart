import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddOrderDescription extends StatelessWidget {
  final String description;
  final double maxWidth;

  const AddOrderDescription({
    super.key,
    required this.description,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      // child: CustomSubTitle(
      //   subtitle: description.isEmpty ? "Empty" : description,
      //   color: AppColor.descraption,
      //   fontsize: 12.sp,
      // ),
      child: Text(
        description.isEmpty ? "Empty" : description,
        style: TextStyle(
          color: AppColor.descraption,
            fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          height: 1.2
        ),
      ),
    );
  }
}

import 'package:breezefood/core/component/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddOrderHeaderImage extends StatelessWidget {
  final String imagePathOrUrl;
  final String shareText;

  const AddOrderHeaderImage({
    super.key,
    required this.imagePathOrUrl,
    required this.shareText,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: AppNetworkImage(
        path: imagePathOrUrl,
        width: double.infinity,
        height: 400.h,
        fit: BoxFit.cover,
      ),
    );
  }
}

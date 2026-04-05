import 'package:flutter/material.dart';

class CustomSubTitle extends StatelessWidget {
  final String subtitle;
  final Color color;
  final double fontsize;
  final double? width;
  const CustomSubTitle({super.key, required this.subtitle, required this.color, required this.fontsize, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        subtitle,
        style: TextStyle(
          fontSize: fontsize,
          color: color,
          fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter',

          fontWeight: FontWeight.w700,
        ),
        maxLines: 2,
        // 👈 سطرين فقط
        overflow: TextOverflow.ellipsis, // 👈 يظهر ...
      ),
    );
  }
}

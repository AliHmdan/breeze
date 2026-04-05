import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget notificationCard({required String title, required String subtitle, required String time, bool isActive = false}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: isActive ? AppColor.primaryColor : AppColor.search, borderRadius: BorderRadius.circular(20)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Circle
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? AppColor.black : AppColor.black,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.LightActive, // لون البوردر
              width: 1, // سماكة الخط
            ),
          ),
          child: SvgPicture.asset('assets/icons/notification.svg', color: Colors.white, width: 20, height: 20),
        ),
        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: AppColor.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(time, style: TextStyle(color: AppColor.white, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: TextStyle(color: isActive ? AppColor.white : AppColor.gry, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    ),
  );
}

import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/help_center/help_center.dart';
import 'package:breezefood/features/notifications/presentation/ui/widget/notification_card.dart';
import 'package:breezefood/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final NotificationCubit cubit;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    cubit = getIt<NotificationCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.openScreen());
  }

  String _timeLabel(DateTime? dt) {
    if (dt == null) return "";
    final now = DateTime.now();
    final d = now.difference(dt.toLocal());

    // ✅ هون نصوص ثابتة -> .tr()
    if (d.inMinutes < 1) return "notifications.time.now".tr();
    if (d.inMinutes < 60) return "notifications.time.minutes".tr(args: ["${d.inMinutes}"]);
    if (d.inHours < 24) return "notifications.time.hours".tr(args: ["${d.inHours}"]);

    return "${dt.toLocal().year}-${dt.toLocal().month.toString().padLeft(2, '0')}-${dt.toLocal().day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90.h),
          child: CustomAppbarProfile(ontap: () => Navigator.pop(context), title: "notifications.title".tr(), icon: Icons.arrow_back_ios),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: BlocBuilder<NotificationCubit, NotificationState>(
            bloc: cubit,
            builder: (context, state) {
              return state.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColor.primaryColor)),
                error: (msg) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        msg, // هذا من السيرفر/الريبو، خليه مثل ما هو
                        style: TextStyle(color: Colors.red, fontSize: 13.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      TextButton(onPressed: () => cubit.openScreen(), child: Text("common.retry".tr())),
                    ],
                  ),
                ),
                loaded: (items, isMarkingAll) {
                  return Column(
                    children: [
                      SizedBox(height: 8.h),
                      if (items.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none, color: AppColor.white, size: 60.sp),
                                SizedBox(height: 10.h),
                                Text(
                                  "notifications.empty".tr(),
                                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final n = items[index];

                              final isActive = selectedIndex == index;
                              final visualActive = isActive || !n.isRead;

                              // ✅ اختيار اللغة صار من الموديل نفسه (شوف تحت)
                              final title = n.titleText(context);
                              final subtitle = n.bodyText(context);

                              final time = _timeLabel(n.sentAt ?? n.createdAt);

                              return GestureDetector(
                                onTap: ()
                                {
                                  setState(() => selectedIndex = index);
                                  switch(n.type){
                                    case "system":;
                                    case"order":
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ResturantDetails(restaurant_id: n.data["restaurant_id"],)));
                                    case "chat":Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HelpCenter()));
                                  }
                                },
                                child: notificationCard(
                                  title: title.isEmpty ? "-" : title,
                                  subtitle: subtitle.isEmpty ? "-" : subtitle,
                                  time: time,
                                  isActive: visualActive,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

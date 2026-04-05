import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart' show UrlHelper;
import 'package:breezefood/features/help_center/data/model/help_center_models.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart' show CustomAppbarProfile;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/help_center/presentation/cubit/help_center_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HelpCenter extends StatefulWidget {
  final String? profileImage;
  const HelpCenter({super.key, this.profileImage});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  late final HelpCenterCubit cubit;
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late final full = UrlHelper.toFullUrl(widget.profileImage);

  @override
  void initState() {
    super.initState();
    cubit = getIt<HelpCenterCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load();
    });
  }

  @override
  void dispose() {
    cubit.close();
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      bloc: cubit,
      builder: (context, state) {
        final ticket = state.ticket;
        final msgs = ticket?.messages ?? const <TicketMessageModel>[];

        // بعد كل تحديث للرسائل نزّل لآخر شي
        _scrollToBottom();

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColor.Dark,
            // appBar: PreferredSize(
            //   preferredSize: Size.fromHeight(60.h),
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 16.w),
            //     child: CustomAppbarProfile(
            //       title: isRtl ? "مركز المساعدة" : 'Help Center',
            //       ontap: () => Navigator.pop(context),
            //       icon: Icons.arrow_back_ios,
            //     ),
            //
            //     // Row(
            //     //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     //   children: [
            //     //     GestureDetector(
            //     //       onTap: () => Navigator.pop(context),
            //     //       child: Container(
            //     //         padding: const EdgeInsets.all(4),
            //     //         decoration: BoxDecoration(
            //     //           color: AppColor.black,
            //     //           shape: BoxShape.circle,
            //     //           border: Border.all(
            //     //             color: AppColor.LightActive,
            //     //             width: 2,
            //     //           ),
            //     //         ),
            //     //         child: Center(
            //     //           child: Icon(
            //     //             Icons.close,
            //     //             color: AppColor.white,
            //     //             size: 16.sp,
            //     //           ),
            //     //         ),
            //     //       ),
            //     //     ),
            //     //     const Spacer(),
            //     //     Text(
            //     //       "Help center",
            //     //       style: TextStyle(
            //     //         fontSize: 16.sp,
            //     //         fontWeight: FontWeight.bold,
            //     //         color: AppColor.white,
            //     //       ),
            //     //     ),
            //     //     const Spacer(),
            //     //   ],
            //     // ),
            //   ),
            // ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                children: [
                  CustomAppbarProfile(
                    title: isRtl ? "مركز المساعدة" : 'Help Center',
                    ontap: () => Navigator.pop(context),
                    icon: Icons.arrow_back_ios,
                  ),
                  // خط مع الحالة بدل الوقت (اختياري)
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Divider(color: AppColor.white, thickness: 0.5)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          state.loading ? "Loading..." : (ticket == null ? "No ticket" : ticket.status.toUpperCase()),
                          style: TextStyle(color: AppColor.white, fontSize: 12.sp),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColor.white, thickness: 0.5)),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  if (state.loading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator(color: AppColor.primaryColor)),
                    )
                  else if (state.error != null)
                    Expanded(
                      child: Center(
                        child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        padding: EdgeInsets.all(10.w),
                        itemCount: msgs.length,
                        itemBuilder: (context, index) {
                          final msg = msgs[index];
                          final isMe = msg.senderType == "customer"; // ✅ حسب API

                          return Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isMe) ...[
                                    // CircleAvatar(
                                    //   // radius: 20.r,
                                    //   // backgroundImage: const AssetImage("assets/images/logo.png"),
                                    //   backgroundColor: AppColor.primaryColor,
                                    //   child: Image.asset("assets/images/logo-removebg.png", width: 90.w),
                                    // ),
                                    SizedBox(width: 6.w),
                                  ],
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (isMe && !isRtl) ...[_buildStatusIcon(isReadByCustomer: msg.isReadByAdmin), SizedBox(width: 4.w)],
                                        Flexible(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                            decoration: BoxDecoration(
                                              color: isMe ? AppColor.primaryColor : AppColor.primaryColor,
                                              borderRadius: BorderRadius.circular(20.r),
                                            ),
                                            child: Text(
                                              msg.message,
                                              style: TextStyle(color: AppColor.white, fontSize: 12.sp),
                                            ),
                                          ),
                                        ),
                                        if (isMe && isRtl) ...[SizedBox(width: 4.w), _buildStatusIcon(isReadByCustomer: msg.isReadByAdmin)],
                                      ],
                                    ),
                                  ),
                                  if (isMe) ...[
                                    SizedBox(width: 6.w),
                                    CircleAvatar(
                                      radius: 20.r,
                                      backgroundImage: full == null || full!.isEmpty
                                          ? AssetImage("assets/images/person.jpg")
                                          : NetworkImage(full ?? ''),
                                    ),
                                  ],
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h, left: isMe ? 0 : 40.w, right: isMe ? 40.w : 0),
                                child: Text(
                                  _formatTime(msg.createdAt),
                                  style: TextStyle(color: AppColor.white, fontSize: 11.sp),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  _buildInputArea(state.sending),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "--:--";
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Widget _buildStatusIcon({required bool isReadByCustomer}) {
    // ✅ بما إن API عندك يعطي is_read_by_admin / is_read_by_customer
    // هون اعتبرنا "read" إذا admin قرأ
    if (isReadByCustomer) {
      return Icon(Icons.done_all, size: 16.sp, color: Colors.blueAccent);
    }
    return Icon(Icons.done_all, size: 16.sp, color: AppColor.primaryColor);
  }

  Widget _buildInputArea(bool sending) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: TextField(
        controller: _ctrl,
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: InkWell(
              onTap: sending
                  ? null
                  : () async {
                      final text = _ctrl.text;
                      _ctrl.clear();
                      await cubit.send(text);
                    },
              child: Icon(sending ? Icons.hourglass_top : Icons.arrow_circle_up_sharp, size: 28.sp, color: AppColor.primaryColor),
            ),
          ),
          hintText: "Message here...",
          hintStyle: TextStyle(color: AppColor.LightActive, fontSize: 13.sp),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
        onSubmitted: sending
            ? null
            : (_) async {
                final text = _ctrl.text;
                _ctrl.clear();
                await cubit.send(text);
              },
      ),
    );
  }
}

/// موديل الرسائل
class Message {
  final String text;
  final String time;
  final bool isSentByMe;
  final MessageStatus status;

  Message({required this.text, required this.time, required this.isSentByMe, required this.status});
}

/// حالات الرسالة
enum MessageStatus { sent, delivered, read }

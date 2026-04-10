import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/dialogs.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/main_shell.dart' show MainShell;
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as my;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class SuccessPopup extends StatefulWidget {
  final String message;
  final String buttonText;

  const SuccessPopup({
    super.key,
    required this.message,
    required this.buttonText,
  });

  @override
  State<SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<SuccessPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppColor.Dark,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColor.primaryColor,
                  size: 70.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // اغلاق الديالوج
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MainShell(isOrderFinished: true),
                      ),
                    );
                  },
                  // onPressed: () => Navigator.pop(context),
                  // onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell(isOrderFinished: true))),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColor.primaryColor,
                    backgroundColor: AppColor.primaryColor,
                  ),
                  child: Text(
                    widget.buttonText,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrackingSheet extends StatefulWidget {
  final int orderId;
  final ScrollController scrollController;

  const TrackingSheet({
    super.key,
    required this.orderId,
    required this.scrollController,
  });

  @override
  State<TrackingSheet> createState() => _TrackingSheetState();
}

class _TrackingSheetState extends State<TrackingSheet> {
  dynamic _cachedDetails;
  String? _cachedErrorKey;
  bool _shownDialog = false; // ✅ مهم
  // ================= Helpers =================

  String absUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    const base = "https://breezefood.cloud/";
    if (path.startsWith("/")) return "$base${path.substring(1)}";
    return "$base$path";
  }

  String _cleanPhone(String s) {
    final cleaned = s.replaceAll(RegExp(r"[^0-9+]"), "");
    return cleaned;
  }

  Future<void> _callPhone(String phone) async {
    final p = _cleanPhone(phone);
    if (p.isEmpty) return;

    final uri = Uri(scheme: "tel", path: p);
    final ok = await canLaunchUrl(uri);
    if (!ok) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> popUpWhenOrderIsCompleted() async {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!mounted) return;

      Future.microtask(() {
        if (!mounted) return;

        showDialog(
          context: context,
          useRootNavigator: true,
          barrierDismissible: true,
          builder: (_) => SuccessPopup(
            message: "reviews.Your_order_was_complete_successfully".tr(),
            buttonText: 'reviews.done'.tr(),
          ),
        );
      });
    });
  }

  // bool _isStepCompleted(String stepKey, String currentStatus) {
  //   const order = ["pending", "preparing", "inway", "delivered"];
  //   final a = order.indexOf(stepKey);
  //   final b = order.indexOf(currentStatus);
  //   final ali = currentStatus;
  //   print('the name of my order');
  //   print('stepKey :$a');
  //   print('currentStatus : $b');
  //   print('currentStatus for ali : $ali');
  //   // if (b == 3) {
  //   //   popUpWhenOrderIsCompleted();
  //   //   //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell(isOrderFinished: true)));
  //   // } else {}
  //   bool _isStepCompleted(String stepKey, String currentStatus) {
  //     const order = ["pending", "preparing", "inway", "delivered"];
  //     final a = order.indexOf(stepKey);
  //     final b = order.indexOf(currentStatus);
  //
  //     if (a == -1 || b == -1) return false;
  //     return a <= b;
  //   }
  //   bool _shownDialog = false;
  //   print('the name of my order');
  //   if (a == -1 || b == -1) return false;
  //   return a <= b;
  // }
  bool _isStepCompleted(String stepKey, String currentStatus) {
    const order = ["pending", "preparing", "inway", "delivered"];
    final a = order.indexOf(stepKey);
    final b = order.indexOf(currentStatus);

    if (a == -1 || b == -1) return false;
    return a <= b;
  }

  String _timeFor(List timeline, String key) {
    for (final e in timeline) {
      try {
        if (e is OrderTimelineStep) {
          if (e.key == key) return (e.time ?? "").toString();
        }
        if (e is Map) {
          final k = (e["key"] ?? "").toString();
          if (k == key) return (e["time"] ?? "").toString();
        }
      } catch (_) {}
    }
    return "";
  }

  String _stepTitle(String key) => "order_status.$key".tr();

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    child: Container(height: 1, color: AppColor.search),
  );

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _v(String? s) => (s == null || s.trim().isEmpty) ? "—" : s.trim();

  Widget _kv(String k, String v) {
    final vv = v.trim().isEmpty ? "—" : v.trim();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: TextStyle(
                color: AppColor.white.withOpacity(0.7),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            vv,
            style: TextStyle(
              color: AppColor.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCircle({required IconData icon, required VoidCallback? onTap}) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Opacity(
          opacity: disabled ? 0.45 : 1,
          child: Ink(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: AppColor.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.white, size: 20.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIcon(bool isCompleted) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: isCompleted ? AppColor.primaryColor : AppColor.LightActive,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check : Icons.circle_outlined,
        color: AppColor.white,
        size: 16.sp,
      ),
    );
  }

  Widget _buildStep(String title, String time, bool isCompleted, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildStepIcon(isCompleted),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? AppColor.primaryColor
                        : AppColor.LightActive,
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColor.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    time.trim().isEmpty ? "—" : time,
                    style: TextStyle(
                      color: AppColor.white.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: isLast ? 0 : 18.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndCancel(BuildContext context) async {
    final ok = await AppDialog.showConfirmDialog(
      title: "orders.cancel_confirm_title".tr(),
      message: "orders.cancel_confirm_body".tr(),
      yesText: "orders.cancel".tr(),
      noText: "common.close".tr(),
      icon: Iconsax.warning_2,
      iconColor: AppColor.red,
    );

    if (ok != true) return;

    final success = await context.read<OrdersDetailsCubit>().cancel(
      widget.orderId,
    );
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("orders.cancel_failed".tr())));
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    const stepKeys = ["pending", "preparing", "inway", "delivered"];

    return BlocListener<OrdersDetailsCubit, OrdersDetailsState>(
      listener: (context, state) {
        // ✅ خزّن آخر نجاح
        // state.whenOrNull(
        //   success: (d) {
        //     _cachedDetails = d;
        //     _cachedErrorKey = null;
        //   },
        //   error: (mKey) {
        //     // ✅ ما نفضي البيانات؛ بس نخزن آخر error key
        //     _cachedErrorKey = mKey;
        //   },
        // );
        state.whenOrNull(
          success: (d) {
            _cachedDetails = d;
            _cachedErrorKey = null;

            final status = (d.order.status ?? "")
                .toString()
                .toLowerCase()
                .trim();

            if (status == "delivered" && !_shownDialog) {
              _shownDialog = true;
              popUpWhenOrderIsCompleted();
            }
          },
          error: (mKey) {
            _cachedErrorKey = mKey;
          },
        );
      },
      child: BlocBuilder<OrdersDetailsCubit, OrdersDetailsState>(
        buildWhen: (prev, curr) {
          // ✅ قلل rebuilds: بنعيد البناء بس عند success أو أول load بدون cache أو error أول مرة
          final hasCache = _cachedDetails != null;

          return curr.maybeWhen(
            success: (_) => true,
            loading: () => !hasCache,
            error: (_) => !hasCache,
            orElse: () => false,
          );
        },
        builder: (context, state) {
          // ✅ source of truth للعرض: cache إذا موجود
          final details = state.maybeWhen(
            success: (d) => d,
            orElse: () => _cachedDetails,
          );

          // ✅ أول مرة فقط: إذا ما في cache نهائياً
          final hasDetails = details != null;

          if (!hasDetails) {
            return Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.Dark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.r),
                    topRight: Radius.circular(25.r),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            );
          }

          // ==== استخراج البيانات من details (كما عندك) ====
          final driverName = _v(details.driver.name);
          final driverPhoneRaw = (details.driver.phone ?? "").toString();
          final driverPhone = _cleanPhone(driverPhoneRaw);
          final driverImg = absUrl(details.driver.profileImage ?? "");

          final restaurantName = _v(details.restaurant.name);
          final restLogo = absUrl(details.restaurant.logo ?? "");

          final order = details.order;
          final status = (order.status ?? "").toString();
          final st = status.toLowerCase().trim();
          final canCancel = st == "no_driver" || st == "pending";

          final isVip = order.isVip == true;

          final itemsTotal = order.itemsTotal;
          final deliveryFee = order.deliveryFee;
          final total = order.totalPrice;

          final codeInt = order.orderCustomerCode;
          final code = (codeInt == null) ? "" : codeInt.toString();
          final codeDigits = code.isEmpty
              ? ["-", "-", "-", "-"]
              : code.padLeft(4, "0").split("");

          final timeline = details.timeline ?? const [];
          final items = details.items ?? const [];

          // ✅ إذا في error أثناء refresh: لا نغير الشاشة
          // بس نظهر سطر صغير خفيف "آخر تحديث فشل" بدون spinner
          final softErrorBar = (_cachedErrorKey != null)
              ? Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.warning_2,
                        color: Colors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _cachedErrorKey!.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.read<OrdersDetailsCubit>().load(
                          widget.orderId,
                        ),
                        child: Text(
                          "common.retry".tr(),
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink();

          return Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.Dark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.r),
                  topRight: Radius.circular(25.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomScrollView(
                  controller: widget.scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // handle
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h, bottom: 12.h),
                        child: Center(
                          child: Container(
                            width: 44.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: AppColor.search,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.LightActive,
                                border: Border.all(
                                  color: AppColor.primaryColor.withOpacity(0.6),
                                  width: 2,
                                ),
                              ),
                              child: driverImg.isEmpty
                                  ? Icon(Icons.person, color: AppColor.white)
                                  : Image.network(
                                      driverImg,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        color: AppColor.white,
                                      ),
                                    ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          driverName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColor.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ),
                                      if (isVip)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColor.primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.emoji_events,
                                                size: 14.sp,
                                                color: AppColor.white,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                "orders.vip_badge".tr(),
                                                style: TextStyle(
                                                  color: AppColor.white,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      if (restLogo.isNotEmpty)
                                        Container(
                                          width: 18.w,
                                          height: 18.w,
                                          margin: EdgeInsets.only(right: 6.w),
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: AppColor.LightActive,
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Image.network(
                                            restLogo,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const SizedBox.shrink(),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          restaurantName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColor.white,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (driverPhone.isNotEmpty) ...[
                                    SizedBox(height: 6.h),
                                    Text(
                                      driverPhone,
                                      style: TextStyle(
                                        color: AppColor.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            _actionCircle(
                              icon: Icons.call,
                              onTap: driverPhone.isEmpty
                                  ? null
                                  : () => _callPhone(driverPhone),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ✅ soft error bar (بدون ما نقلب UI)
                    SliverToBoxAdapter(child: softErrorBar),

                    // body
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _divider(),

                          _sectionTitle("tracking.customer_code_title".tr()),
                          Text(
                            "tracking.show_code_hint".tr(),
                            style: TextStyle(
                              color: AppColor.white.withOpacity(0.7),
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Directionality(
                            textDirection: my.TextDirection.ltr,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 14.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.search,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(
                                  4,
                                  (i) => Text(
                                    codeDigits[i],
                                    style: TextStyle(
                                      color: AppColor.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          _divider(),

                          _sectionTitle("tracking.order_details".tr()),
                          _kv(
                            "tracking.status".tr(),
                            st.isEmpty ? "—" : "order_status.$st".tr(),
                          ),
                          _kv(
                            "tracking.items_total".tr(),
                            context.syp(itemsTotal),
                          ),
                          _kv(
                            "tracking.delivery_fee".tr(),
                            context.syp(deliveryFee),
                          ),
                          _kv("tracking.total".tr(), context.syp(total)),

                          if (canCancel) ...[
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.close),
                                label: Text("orders.cancel_order".tr()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                onPressed: () => _confirmAndCancel(context),
                              ),
                            ),
                          ],

                          _divider(),

                          _sectionTitle("tracking.timeline".tr()),
                          ...List.generate(stepKeys.length, (i) {
                            final k = stepKeys[i];
                            final t = _timeFor(timeline, k);
                            return _buildStep(
                              _stepTitle(k),
                              t,
                              _isStepCompleted(k, st),
                              i == stepKeys.length - 1,
                            );
                          }),

                          _divider(),

                          _sectionTitle("tracking.items".tr()),
                          if (items.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                "common.empty".tr(),
                                style: TextStyle(color: AppColor.gry),
                              ),
                            )
                          else
                            ...items.map((it) {
                              final img = absUrl(it.image);
                              return Container(
                                margin: EdgeInsets.only(bottom: 10.h),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: AppColor.search,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52.w,
                                      height: 52.w,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        color: AppColor.Dark,
                                      ),
                                      child: img.isEmpty
                                          ? Icon(
                                              Icons.fastfood,
                                              color: AppColor.white,
                                            )
                                          : Image.network(
                                              img,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                    Icons.fastfood,
                                                    color: AppColor.white,
                                                  ),
                                            ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            it.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppColor.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Wrap(
                                            spacing: 8.w,
                                            runSpacing: 6.h,
                                            children: [
                                              _chipKV(
                                                "tracking.qty".tr(),
                                                "${it.quantity}",
                                              ),
                                              _chipKV(
                                                "tracking.item_price".tr(),
                                                context.syp(it.totalPrice),
                                              ),
                                              _chipKV(
                                                "tracking.delivery_time".tr(),
                                                "${it.deliveryTime}",
                                              ),
                                            ],
                                          ),
                                          if (it.withSpicy)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.h,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 6.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColor.Dark,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  border: Border.all(
                                                    color: Colors.white12,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .local_fire_department,
                                                      color: AppColor.white,
                                                      size: 16.sp,
                                                    ),
                                                    SizedBox(width: 6.w),
                                                    Text(
                                                      "tracking.spicy".tr(),
                                                      style: TextStyle(
                                                        color: AppColor.white,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _chipKV(String label, String value) {
  final v = value.trim().isEmpty ? "—" : value.trim();

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: AppColor.Dark,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            color: AppColor.white.withOpacity(0.7),
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          v,
          style: TextStyle(
            color: AppColor.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

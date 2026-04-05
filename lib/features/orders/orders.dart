import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/app/bloc/app_cubit.dart' show AppCubit;
import 'package:breezefood/features/orders/orders_history.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ تحميل الطلبات السابقة فقط
      context.read<OrdersCubit>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = AppCubit.get(context).isThemDark();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.Dark,

        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // icons color
      ),
      child: Scaffold(
        backgroundColor: AppColor.Dark,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbarProfile(title: "cart.orders_history".tr(), ontap: () {}),

            SizedBox(height: 16.h),

            // ✅ عرض Orders History فقط
            const Expanded(child: OrdersHistory()),
          ],
        ),
      ),
    );
  }
}

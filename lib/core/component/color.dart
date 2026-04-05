import 'package:breezefood/core/router/navigation_key.dart' show NavigationKey;
import 'package:breezefood/features/app/bloc/app_cubit.dart' show AppCubit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class AppColor {
  // static const Color white = Color(0xffFFFFFF);
  // static const Color white = Color(0xffffffff);
  static Color get white {
    final ctx = NavigationKey.navigatorKey.currentContext;

    // if (ctx == null) return const Color(0xffFFFFFF);
    if (ctx == null) return const Color(0xFFF9FAFB);

    final isDark = AppCubit.get(ctx).isThemDark();
    // return isDark ? const Color(0xffFFFFFF) : const Color(0xff000201);
    return isDark ? const Color(0xFFF9FAFB) : const Color(0xff000201);
  }

  // static const Color light = Color(0xffF2F2F2);
  static Color get light {
    final ctx = NavigationKey.navigatorKey.currentContext;

    if (ctx == null) return const Color(0xffF2F2F2);

    final isDark = AppCubit.get(ctx).isThemDark();
    return isDark ? const Color(0xffF2F2F2) : const Color(0xff1A1A1A);
  }

  // static const Color search = Color(0xff1A1A1A);
  static Color get search {
    final ctx = NavigationKey.navigatorKey.currentContext;

    if (ctx == null) return const Color(0xff363535);

    final isDark = AppCubit.get(ctx).isThemDark();
    return isDark
        // ? const Color(0xff1A1A1A)
        ? const Color(0xff363535)
        :
          // const Color(0xffF2F4F7);
          const Color(0xffd9d6d6);
    // Color(0xffF2F2F2);
  }

  // static const Color Dark = Color(0xff000201);
  static Color get Dark {
    final ctx = NavigationKey.navigatorKey.currentContext;

    if (ctx == null) return const Color(0xff000201);

    final isDark = AppCubit.get(ctx).isThemDark();
    return isDark ? const Color(0xff000201) : const Color(0xFFFFFFFF);
  }

  // static const Color gryLighter = Color(0xffd5d2d2);
  static Color get gryLighter {
    final ctx = NavigationKey.navigatorKey.currentContext;

    if (ctx == null) return const Color(0xffd5d2d2);

    final isDark = AppCubit.get(ctx).isThemDark();
    return isDark ? const Color(0xffd5d2d2) : const Color(0xFF4B4D4D);
  }

  ///
  /// do not change
  ///
  static const Color red = Color(0xffB71C1C);
  static const Color green = Color(0xff77DD98);
  static const Color yellow = Color(0xffF2E665);
  static const Color primaryColor = Color(0xff2ECC71);
  static const Color LightActive = Color(0xff757575);
  // static const Color gry = Color(0xff6B7280);
  ///6B7280
  ///
  ///
  static const Color gry = Color(0xFF9E9E9E);
  static const Color descraption = Color(0xFF707070);
  static const Color lightblack = Color(0xff6B7280);
  static Color get gryForNavBar {
    final ctx = NavigationKey.navigatorKey.currentContext;

    if (ctx == null) return const Color(0xffCFCFCF);

    final isDark = AppCubit.get(ctx).isThemDark();
    return isDark ? const Color(0xffCFCFCF) : const Color(0xff212121);
  }

  //  =============================================================

  static const Color black = Color(0xff212121);

  static const Color backfilter = Color(0xff3D3D3D);
  static const Color grye = Color(0xff334155);
  static const Color Lightgry = Color(0xffCBD5E1);
}

// class AppColor {
//   static const Color white = Color(0xFFF9FAFB);
//   static const Color light = Color(0xffF2F2F2);
//   static const Color search = Color(0xff1A1A1A);
//   static const Color Dark = Color(0xff000201);
//   static const Color gryLighter = Color(0xffd5d2d2);
//   static const Color red = Color(0xffB71C1C);
//   static const Color green = Color(0xff77DD98);
//   static const Color yellow = Color(0xffF2E665);
//   static const Color primaryColor = Color(0xff2ECC71);
//   static const Color LightActive = Color(0xff757575);
//   static const Color gry = Color(0xFF9E9E9E);
//   static const Color descraption = Color(0xFF707070);
//   static const Color lightblack = Color(0xff6B7280);
//   static const Color gryForNavBar = Color(0xffCFCFCF);
//   static const Color black = Color(0xff212121);
//   static const Color backfilter = Color(0xff3D3D3D);
//   static const Color grye = Color(0xff334155);
//   static const Color Lightgry = Color(0xffCBD5E1);
// }

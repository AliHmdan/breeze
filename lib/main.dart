// import 'package:breezefood/core/component/color.dart';
// import 'package:breezefood/core/component/loading.dart';
// import 'package:breezefood/core/di/di.dart';
// import 'package:breezefood/core/router/navigation_key.dart';
// import 'package:breezefood/core/services/app_notification_service.dart';
// import 'package:breezefood/core/services/launch_screen.dart';
// import 'package:breezefood/core/services/restart_widget.dart';
// import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
// import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
// import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
// import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'features/app/bloc/app_cubit.dart';
//
// final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//
//   configEasyLoading();
//
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark),
//   );
//
//   await setupDi();
//   await AppNotificationService.init();
//
//   runApp(
//     EasyLocalization(
//       supportedLocales: const [Locale('en'), Locale('ar')],
//       path: 'assets/translations',
//       fallbackLocale: const Locale('en'),
//       saveLocale: true,
//       child: const RestartWidget(child: MyApp()),
//     ),
//   );
//
//   final fcm = await FirebaseMessaging.instance.getToken();
//   print(fcm);
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     configEasyLoading();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider.value(value: getIt<HomeCubit>()),
//         BlocProvider.value(value: getIt<ProfileCubit>()),
//         BlocProvider.value(value: getIt<CartCubit>()),
//         BlocProvider(create: (_) => getIt<FavoritesCubit>()),
//         BlocProvider(create: (_) => AppCubit()..getThem()),
//       ],
//       child: ScreenUtilInit(
//         designSize: const Size(393, 852),
//         minTextAdapt: true,
//         splitScreenMode: true,
//         builder: (_, __) {
//           return BlocConsumer<AppCubit, AppState>(
//             listener: (context, state) {
//               final isDark = AppCubit.get(context).isThemDark();
//               EasyLoading.instance
//                 ..backgroundColor = isDark ? Colors.black : Colors.white
//                 ..indicatorColor = isDark ? Colors.white : Colors.black
//                 ..textColor = isDark ? Colors.white : Colors.black;
//             },
//             builder: (context, state) {
//               final isDark = AppCubit.get(context).isThemDark();
//
//               SystemChrome.setSystemUIOverlayStyle(
//                 SystemUiOverlayStyle(
//                   statusBarColor: Colors.transparent,
//                   statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
//                   statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
//                 ),
//               );
//
//               return MaterialApp(
//                 navigatorObservers: [routeObserver],
//                 navigatorKey: NavigationKey.navigatorKey,
//                 debugShowCheckedModeBanner: false,
//                 title: 'breeze food UI',
//                 home: const LaunchScreen(),
//                 locale: context.locale,
//                 supportedLocales: context.supportedLocales,
//                 localizationsDelegates: context.localizationDelegates,
//                 themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
//                 theme: ThemeData(
//                   useMaterial3: true,
//                   colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor, brightness: Brightness.light),
//                 ),
//                 darkTheme: ThemeData(
//                   useMaterial3: true,
//                   colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor, brightness: Brightness.dark),
//                 ),
//                 builder: (context, widget) {
//                   final wrapped = MediaQuery(
//                     data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
//                     child: widget ?? const SizedBox.shrink(),
//                   );
//
//                   final isArabic = Localizations.localeOf(context).languageCode == 'ar';
//
//                   return Theme(
//                     data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(fontFamily: isArabic ? 'Cairo' : 'Inter')),
//                     child: EasyLoading.init()(context, wrapped),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:breezefood/core/component/loading.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/router/navigation_key.dart';
import 'package:breezefood/core/services/app_notification_service.dart';
import 'package:breezefood/core/services/launch_screen.dart';
import 'package:breezefood/core/services/restart_widget.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/app/bloc/app_cubit.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  configEasyLoading();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark),
  );

  await setupDi();
  await AppNotificationService.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: const RestartWidget(child: MyApp()),
    ),
  );

  final fcm = await FirebaseMessaging.instance.getToken();
  print(fcm);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    configEasyLoading();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<HomeCubit>()),
        BlocProvider.value(value: getIt<ProfileCubit>()),
        BlocProvider.value(value: getIt<CartCubit>()),
        BlocProvider(create: (_) => getIt<FavoritesCubit>()),
        BlocProvider(create: (_) => AppCubit()..getThem()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) {
          return BlocConsumer<AppCubit, AppState>(
            listener: (context, state) {
              final isDark = AppCubit.get(context).isThemDark();

              EasyLoading.instance
                ..backgroundColor = isDark ? Colors.black : Colors.white
                ..indicatorColor = isDark ? Colors.white : Colors.black
                ..textColor = isDark ? Colors.white : Colors.black;
            },
            builder: (context, state) {
              final isDark = AppCubit.get(context).isThemDark();

              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                ),
              );

              return MaterialApp(
                navigatorObservers: [routeObserver],
                navigatorKey: NavigationKey.navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'breeze food UI',
                home: const LaunchScreen(),
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
                ),
                builder: (context, widget) {
                  final wrapped = MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: widget ?? const SizedBox.shrink(),
                  );

                  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

                  return Theme(
                    data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(fontFamily: isArabic ? 'Cairo' : 'Inter')),
                    child: EasyLoading.init()(context, wrapped),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

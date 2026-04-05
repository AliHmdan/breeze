import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/loading.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/router/navigation_key.dart';
import 'package:breezefood/core/services/app_notification_service.dart';
import 'package:breezefood/core/services/launch_screen.dart';
import 'package:breezefood/core/services/restart_widget.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart' show AuthStorageHelper;
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/main_shell.dart';
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

///
/// NOTE FOR APP
/// removeBack,saveBack,getBack used in hive to save the user action on home screen if he press the back button
/// it wiil seve the statues and detect it in the main to launch the mainShall or launcher screen
/// ///////////////////////////////

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  configEasyLoading();

  await setupDi();
  await AppNotificationService.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child:
          // const RestartWidget(child:
          MyApp(),
      // ),
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String? userBack;

  Future<void> getBackArrow() async {
    userBack = await AuthStorageHelper.getBack();
    print('userBack:$userBack');
  }

  @override
  void initState() {
    super.initState();

    configEasyLoading();
    WidgetsBinding.instance.addObserver(this);
    getBackArrow();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// when back button and remove app with button  ////////////////////////////////////////////
    if (state == AppLifecycleState.inactive) {
      print('???????????????????????????????????????');
      print('inactive');
      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      print('sssssssssssssssss');
      print('ddddddddddd');
      print('ffff');
      print('qq');
    }
    if (state == AppLifecycleState.hidden) {
      print('???????????????????????????????????????');
      print('hidden');
      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      print('sssssssssssssssss');
      print('ddddddddddd');
      print('ffff');
      print('qq');
    }
    if (state == AppLifecycleState.paused) {
      print('???????????????????????????????????????');
      print('paused');
      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      print('sssssssssssssssss');
      print('ddddddddddd');
      print('ffff');
      print('qq');
    }

    /// here just back button
    if (state == AppLifecycleState.detached) {
      print('???????????????????????????????????????');
      print('detached');
      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      print('sssssssssssssssss');
      print('ddddddddddd');
      print('ffff');
      print('qq');
    }

    /// ////////////////////////////////////////////////////
    if (state == AppLifecycleState.resumed) {
      print('???????????????????????????????????????');
      print('resumed');
      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      print('sssssssssssssssss');
      print('ddddddddddd');
      print('ffff');
      print('qq');
    }
    if (state == AppLifecycleState.values) {
      print('???????????????????????????????????????');
      print('${AppLifecycleState.values}');
      print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      print('sssssssssssssssss');
      print('ddddddddddd');
      print('ffff');
      print('qq');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<HomeCubit>()),
        BlocProvider.value(value: getIt<ProfileCubit>()),
        BlocProvider.value(value: getIt<CartCubit>()),

        // ✅ Factory → create مرة وحدة هون
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
                  statusBarColor: AppColor.Dark,
                  // statusBarColor: AppColor.red,
                ),
              );
              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

              return MaterialApp(
                navigatorObservers: [routeObserver],
                navigatorKey: NavigationKey.navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'breeze food UI',

                home: userBack != null ? MainShell() : LaunchScreen(),

                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,

                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  useMaterial3: true,
                  scaffoldBackgroundColor: AppColor.Dark,
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light),
                  // appBarTheme: Color(0xffd9d6d6),
                  // appBarTheme: AppBarThemeData(
                  //   // backgroundColor: Color(0xffd9d6d6),
                  //   systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Color(0xffd9d6d6)),
                  // ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  scaffoldBackgroundColor: AppColor.Dark,
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
                  // appBarTheme: Color(0xff363535),
                  // appBarTheme: AppBarThemeData(
                  //   // backgroundColor:Color(0xff363535),
                  //   systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Color(0xff363535)),
                  // ),
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

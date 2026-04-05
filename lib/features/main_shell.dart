import 'package:breezefood/core/component/CustomBottomNav.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart' show AuthStorageHelper;
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/home_screen.dart';
import 'package:breezefood/features/favorite_page/presentation/ui/favorite_page.dart';
import 'package:breezefood/features/orders/orders.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breezefood/features/profile/presentation/ui/profile.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/stores_nav_tab.dart';
import 'package:easy_localization/easy_localization.dart' show StringTranslateExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class SuccessPopup extends StatefulWidget {
//   final String message;
//   final String buttonText;
//
//   const SuccessPopup({super.key, required this.message, required this.buttonText});
//
//   @override
//   State<SuccessPopup> createState() => _SuccessPopupState();
// }
//
// class _SuccessPopupState extends State<SuccessPopup> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;
//   late Animation<double> _fade;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
//
//     _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
//
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: ScaleTransition(
//         scale: _scale,
//         child: Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//           backgroundColor: AppColor.Dark,
//           child: Padding(
//             padding: EdgeInsets.all(24.w),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.check_circle, color: AppColor.primaryColor, size: 70.w),
//                 SizedBox(height: 16.h),
//                 Text(
//                   widget.message,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColor.white),
//                 ),
//                 SizedBox(height: 20.h),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(foregroundColor: AppColor.primaryColor, backgroundColor: AppColor.primaryColor),
//                   child: Text(widget.buttonText, style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MainShell extends StatefulWidget {
  final int initialIndex;
  final bool? isOrderFinished;
  const MainShell({super.key, this.initialIndex = 0, this.isOrderFinished});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  late final FavoritesCubit _favoritesCubit;

  final _pages = <Widget>[
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<HomeCubit>()),
        BlocProvider.value(value: getIt<ProfileCubit>()),
        BlocProvider.value(value: getIt<CartCubit>()),
        BlocProvider(create: (_) => getIt<OrderFlowCubit>()), // هاد عادي
      ],
      child: const Home(),
    ),
    // StoresNavTab(),
    FavoritePage(),
    BlocProvider(create: (_) => getIt<OrdersCubit>()..loadHistory(), child: Orders()),
    Profile(),
  ];

  Future<void> removeBackArrow() async {
    await AuthStorageHelper.removeBack();
  }

  // Future<void> popUpWhenOrderIsCompleted() async {
  //   Future.delayed(const Duration(seconds: 3)).then((_) {
  //     if (!mounted) return;
  //
  //     Future.microtask(() {
  //       if (!mounted) return;
  //
  //       showDialog(
  //         context: context,
  //         useRootNavigator: true,
  //         barrierDismissible: true,
  //         builder: (_) => SuccessPopup(message: "reviews.Your_order_was_complete_successfully".tr(), buttonText: 'reviews.done'.tr()),
  //       );
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();

    removeBackArrow();

    _index = widget.initialIndex;

    _favoritesCubit = getIt<FavoritesCubit>();

    if (_index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _favoritesCubit.load();
      });
    }
  }

  @override
  void dispose() {
    _favoritesCubit.close();
    super.dispose();
  }

  void _onTabChanged(int i) {
    setState(() => _index = i);

    if (i == 2) {
      _favoritesCubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        // bool _dialogShown = false;
        // state.maybeWhen(
        //   loaded: (data) {
        //     if (!_dialogShown && widget.isOrderFinished == true) {
        //       _dialogShown = true;
        //       popUpWhenOrderIsCompleted();
        //     }
        //   },
        //   orElse: () {},
        // );
      },

      child: BlocProvider.value(
        value: _favoritesCubit,
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              print("Back button pressed!");
              await AuthStorageHelper.saveBack('aaa');
              // run your logic here
              // e.g. save route, stop video, pause app logic

              return true; // allow back navigation
            },
            child: Scaffold(
              backgroundColor: AppColor.Dark,
              extendBody: true,
              body: IndexedStack(index: _index, children: _pages),

              bottomNavigationBar: BottomNavBreeze(currentIndex: _index, onChanged: _onTabChanged),
            ),
          ),
        ),
      ),
    );
  }
}

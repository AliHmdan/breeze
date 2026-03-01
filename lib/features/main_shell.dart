import 'package:breezefood/core/component/CustomBottomNav.dart';
import 'package:breezefood/core/di/di.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

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
    BlocProvider(create: (_) => getIt<OrdersCubit>(), child: Orders()),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
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
    return BlocProvider.value(
      value: _favoritesCubit,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          extendBody: true,
          body: IndexedStack(index: _index, children: _pages),

          bottomNavigationBar: BottomNavBreeze(currentIndex: _index, onChanged: _onTabChanged),
        ),
      ),
    );
  }
}

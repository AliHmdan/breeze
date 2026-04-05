import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:breezefood/features/auth/presentation/login_page.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/main_shell.dart';
import 'package:breezefood/features/splash_screen/splash_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final hasToken = await AuthStorageHelper.hasToken();

    if (!mounted) return;

    if (hasToken) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(create: (context) => getIt<FavoritesCubit>(), child: const SplashVideoScreen()),
        ),
      );
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

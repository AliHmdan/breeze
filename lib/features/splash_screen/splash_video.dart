import 'dart:async';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/main_shell.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashVideoScreen extends StatefulWidget {
  const SplashVideoScreen({Key? key}) : super(key: key);

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late final VideoPlayerController _controller;
  Timer? _timer;

  late final Future<void> _bootstrapFuture;

  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
    _initVideo();
  }

  Future<void> _bootstrap() async {
    final home = getIt<HomeCubit>();
    final profile = getIt<ProfileCubit>();
    final cart = getIt<CartCubit>();

    // لو فشل GPS ما بدنا نوقف كل شيء
    // try {
    //   await home.sendMyLocationOnce();
    // } catch (_) {}
    //
    // // load كلاتهم سوا
    // await Future.wait([home.load(), profile.load(), cart.loadCart()]);
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset('assets/video/splachscreene.mp4');
    _controller.setLooping(false);
    _controller.setVolume(_isMuted ? 0.0 : 1.0);
    _controller.setPlaybackSpeed(1.5);

    await _controller.initialize();
    if (!mounted) return;

    setState(() {});
    _controller.play();

    // بعد 8 ثواني منبلّش الانتقال (وبنستنى bootstrap)
    _timer = Timer(const Duration(milliseconds: 1900), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    _timer?.cancel();

    // استنى اللود يخلص (بس ما تفشل التنقل إذا صار خطأ)
    try {
      await _bootstrapFuture;
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  Future<void> _toggleMute() async {
    _isMuted = !_isMuted;
    if (!mounted) return;
    setState(() {});
    await _controller.setVolume(_isMuted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialized = _controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (initialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // 👈 هذا المهم
                child: SizedBox(width: _controller.value.size.width, height: _controller.value.size.height, child: VideoPlayer(_controller)),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // ✅ مؤشر صغير فقط إذا الفيديو شغال ولسا اللود ما خلص
          Positioned(
            bottom: 22,
            left: 22,
            child: FutureBuilder<void>(
              future: _bootstrapFuture,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.done) {
                  return const SizedBox.shrink();
                }
                return const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
              },
            ),
          ),

          // ✅ زر الصوت
          if (initialized)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.black.withOpacity(0.35),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up), color: Colors.white, onPressed: _toggleMute),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

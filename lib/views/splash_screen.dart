import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:n_square_international/routes/app_routes.dart';
import '../utils/hive_service/hive_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();

    // 👇 UI pehle load hone do, phir video init karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
    });
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/video/SHORTS(1).mp4',
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );

      // 👇 Ensure full initialization
      await _controller!.initialize();

      // 👇 Small delay (important for slow devices)
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_controller!.value.isInitialized) {
        throw Exception("Video not initialized");
      }

      // 👇 Loop + play
      await _controller!.setLooping(true);
      await _controller!.setVolume(0);
      await _controller!.play();

      setState(() {});
      // 👇 Ensure it keeps playing
      _controller!.addListener(() {
        if (_controller!.value.isInitialized &&
            !_controller!.value.isPlaying) {
          _controller!.play();
        }
      });


      // 👇 Navigation timer (after video starts)
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && !_isNavigated) {
          _isNavigated = true;
          _navigateNext();
        }
      });
      //   final isFinished = _controller!.value.position >=
      //       _controller!.value.duration;
      //
      //   if (isFinished && !_isNavigated) {
      //     _isNavigated = true;
      //     _navigateNext();
      //   }
      // });
    } catch (e) {
      debugPrint("VIDEO ERROR: $e");

      // 👇 fallback navigation
      Future.delayed(const Duration(seconds: 2), () {
        _navigateNext();
      });
    }
  }

  void _navigateNext() {
    if (HiveService.isLogin()) {
      Get.offAllNamed(AppRoutes.myHome);
    } else {
      Get.offAllNamed(AppRoutes.welcomePage);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller != null && _controller!.value.isInitialized
          ? SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      )
          : const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/routes/app_routes.dart';
import '../utils/hive_service/hive_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (HiveService.isLogin()) {
        Get.offAllNamed(AppRoutes.myHome);
      } else {
        Get.offAllNamed(AppRoutes.welcomePage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset(AppImages.logo)],
        ),
      ),
    );
  }
}

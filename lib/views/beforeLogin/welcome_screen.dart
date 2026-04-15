import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/viewModel/beforeLogin/auth_controller.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔥 Background Image
          Image.asset(
            AppImages.background,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          /// 🔥 DARK OVERLAY (IMPORTANT FIX)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 🔥 BLUR EFFECT (Premium Look)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          /// 🔥 CONTENT
          Column(
            children: [
              const Spacer(),

              /// 🌟 LOGO (NOW CLEAR)
              Container(
                padding: const EdgeInsets.all(16),
                // decoration: BoxDecoration(
                //   color: Colors.white.withOpacity(0.1),
                //   // shape: BoxShape.circle,
                // ),
                child: Image.asset(
                  AppImages.logo,
                  height: 150,
                  width: 150,
                ),
              ),

              // const SizedBox(height: 20),

              /// 🌟 GLASS TEXT CONTAINER
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      AppImages.logowelcome,
                      height: 80,
                      width: 550,
                    ),
                    // const SizedBox(height: 6),
                    const Text(
                      "WHERE   IDEAS   TAKES   THE   LEAD",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CustomButton(
                  title: "Continue with Mobile Number",
                  onPressed: () {
                    Get.toNamed(AppRoutes.login);
                  },
                ),
              ),

              const Spacer(),

              const SizedBox(height: 25),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
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
          /// Background Image
          Image.asset(
            AppImages.background,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          backgroundGradient(),

          /// Bottom Login Section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    title: "Continue with Mobile Number",
                    onPressed: () {
                      Get.toNamed(AppRoutes.login);
                    },
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "OR",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 12),

                  Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : GestureDetector(
                        onTap: () => controller.signInWithGoogle(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AppImages.google, width: 40, height: 40),
                            const SizedBox(width: 10),
                            const Text(
                              "Sign in with Google",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            )
                          ],
                        ),
                      ),
                  ),

                  // SafeArea(
                  //   child: CustomGradientButton(
                  //     title: "Skip for now",
                  //     onPressed: () {
                  //       Get.toNamed(AppRoutes.myHome);
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/custom_textfield.dart';
import 'package:n_square_international/viewModel/beforeLogin/auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPhoneTextField(
                    controller: controller.ctr,
                    hintText: "Enter your phone number",
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter phone number";
                      }
                      if (value.length < 10) {
                        return "Please enter valid phone number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  CustomButton(
                    title: "Send Otp",
                    onPressed: () {
                      controller.submit();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D0D0D),
                Color(0xFF1A0000),
                Color(0xFF2B0000),
                Color(0xFF000000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        /// Rotated Image
        Image.asset(
          AppImages.background,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        /// Dark overlay
        Container(color: Colors.black.withOpacity(0.7)),

        child,
      ],
    );
  }
}

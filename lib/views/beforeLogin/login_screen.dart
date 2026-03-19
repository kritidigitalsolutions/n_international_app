import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/custom_textfield.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/beforeLogin/auth_controller.dart';
import 'package:n_square_international/views/afterLogin/profile/privacy_policy_page.dart';

import '../../utils/custom_snakebar.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final controller = Get.put(LoginController());

  void _showPrivacyPolicyPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Expanded(child: PrivacyPolicyPage()),
          ],
        ),
      ),
    );
  }

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
                  const SizedBox(height: 16),
                  
                  Obx(() => Row(
                    children: [
                      Theme(
                        data: ThemeData(unselectedWidgetColor: AppColors.white),
                        child: Checkbox(
                          value: controller.isPrivacyAccepted.value,
                          activeColor: AppColors.primary,
                          checkColor: AppColors.white,
                          onChanged: (bool? value) {
                            controller.isPrivacyAccepted.value = value ?? false;
                          },
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: text12(color: AppColors.textSecondary),
                            children: [
                              const TextSpan(text: "I agree to the "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: text12(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showPrivacyPolicyPopup(context);
                                  },
                              ),
                              const TextSpan(text: " and Terms of Service"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),

                  const SizedBox(height: 20),

                  Obx(() => Opacity(
                    opacity: controller.isPrivacyAccepted.value ? 1.0 : 0.5,
                    child: CustomButton(
                      title: "Send Otp",
                      onPressed: controller.isPrivacyAccepted.value 
                        ? () {
                            controller.submit();
                          }
                        : () {
                        CustomSnackbar.showError(
                          title: "Error",
                          message: "Plz, Read our privacy policy and accept ",
                        );
                      }, // Do nothing if not accepted
                    ),
                  )),
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

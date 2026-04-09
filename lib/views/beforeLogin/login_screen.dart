import 'dart:ui';
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
import 'auth_backgrounnd.dart';

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    /// 🌟 LOGO
                    Image.asset(
                      AppImages.logo2,
                      height: 200,
                    ),

                    const SizedBox(height: 20),

                    /// 🌟 GLASS CARD
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              /// PHONE FIELD
                              CustomPhoneTextField(
                                controller: controller.ctr,
                                hintText: "Enter your phone number",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter phone number";
                                  }
                                  if (value.length < 10) {
                                    return "Enter valid number";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              /// PRIVACY CHECKBOX
                              Obx(() => Row(
                                children: [
                                  Checkbox(
                                    value: controller
                                        .isPrivacyAccepted.value,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      controller
                                          .isPrivacyAccepted.value =
                                          val ?? false;
                                    },
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: text12(
                                            color: Colors.white70),
                                        children: [
                                          const TextSpan(
                                              text: "I agree to the "),
                                          TextSpan(
                                            text: "Privacy Policy",
                                            style: text12(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                _showPrivacyPolicyPopup(
                                                    context);
                                              },
                                          ),
                                          const TextSpan(
                                              text:
                                              " and Terms of Service"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),

                              const SizedBox(height: 20),

                              /// 🚀 SEND OTP BUTTON WITH LOADER
                              Obx(() => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: controller
                                      .isPrivacyAccepted.value
                                      ? () async {
                                    if (!controller.formKey
                                        .currentState!
                                        .validate()) return;

                                    controller.isLoading.value =
                                    true;

                                    await controller.submit();

                                    controller.isLoading.value =
                                    false;
                                  }
                                      : () {
                                    CustomSnackbar.showError(
                                      title: "Error",
                                      message:
                                      "Accept privacy policy first",
                                    );
                                  },
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:
                                    CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Text(
                                    "Send OTP",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/beforeLogin/auth_controller.dart';
import '../../utils/otp_textfield.dart';
import 'auth_backgrounnd.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final OtpController controller = Get.put(OtpController());

  @override
  void initState() {
    super.initState();
    controller.focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// 🔥 LOGO
                  Image.asset(
                    AppImages.logo,
                    height: 150,
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 GLASS CARD
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
                            /// TITLE
                            const Text(
                              "Verify OTP",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// SUBTITLE
                            const Text(
                              "Enter the 6-digit code sent to your number",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 25),

                            /// OTP BOXES
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                6,
                                    (index) => OtpTextField(
                                  index: index,
                                  controller:
                                  controller.otpControllers[index],
                                  focusNode: controller.focusNodes[index],
                                  onChanged: (value) =>
                                      controller.onOtpChanged(value, index),
                                  onBackspace:
                                  controller.handleBackspace,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            /// CONTINUE BUTTON
                            Obx(
                                  () => CustomGradientButton(
                                title: "Verify & Continue",
                                isLoading: controller.isLoading.value,
                                onPressed: controller.submitOtp,
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// RESEND
                            GestureDetector(
                              onTap: () {
                                controller.resendOtp();
                              },
                              child: const Text(
                                "Didn't receive OTP? Resend",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
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
    );
  }
}

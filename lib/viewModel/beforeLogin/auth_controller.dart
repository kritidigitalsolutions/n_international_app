import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';

class LoginController extends GetxController {
  final TextEditingController ctr = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  void submit() {
    if (formKey.currentState!.validate()) {
      CustomSnackbar.showSuccess(
        title: "Success",
        message: "Otp send successfully",
      );
      Get.toNamed(AppRoutes.otp);
    } else {
      CustomSnackbar.showSuccess(
        title: "Error",
        message: "Something went wrong",
      );
    }
  }
}

class OtpController extends GetxController {
  final int otpLength = 4;

  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    otpControllers = List.generate(
      otpLength,
      (index) => TextEditingController(),
    );
    focusNodes = List.generate(otpLength, (index) => FocusNode());
    super.onInit();
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < otpLength - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    }
  }

  void handleBackspace(int index) {
    if (otpControllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String getOtp() {
    return otpControllers.map((e) => e.text).join();
  }

  void submitOtp() async {
    String otp = getOtp();

    if (otp.length < otpLength) {
      Get.snackbar("Error", "Please enter complete OTP");
      return;
    }

    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2)); // simulate API

    isLoading.value = false;

    Get.snackbar("Success", "OTP Verified: $otp");
    Get.toNamed(AppRoutes.fullName);
  }

  @override
  void onClose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}

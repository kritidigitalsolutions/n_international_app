import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';
import '../../repo/auth_repo.dart';
import '../../utils/hive_service/hive_service.dart';
import '../../utils/hive_service/userdetail.dart';

class LoginController extends GetxController {
  final TextEditingController ctr = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  var isLoading = false.obs;
  var isPrivacyAccepted = false.obs;
  
  final _repo = AuthRepo();
  
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Please fill all fields correctly",
      );
      return;
    }
    
    if (!isPrivacyAccepted.value) {
      CustomSnackbar.showError(
        title: "Action Required",
        message: "Please check the privacy policy checkbox",
      );
      return;
    }
    
    isLoading.value = true;
    try {
      await _repo.sendOtp(ctr.text.trim());
      CustomSnackbar.showSuccess(
        title: "Success",
        message: "Otp send successfully",
      );
      Get.toNamed(
        AppRoutes.otp,
        arguments: ctr.text.trim(),
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Something went wrong. Please try again later",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
/// otp controller

class OtpController extends GetxController {
  final isLoading = false.obs;
  late String phone;
  final _repo = AuthRepo();
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  @override
  void onInit() {
    phone = Get.arguments;
    super.onInit();
  }
  // OTP input change
  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    // auto submit when last digit entered
    if (index == 5 && value.isNotEmpty) {
      submitOtp();
    }
  }
  // Handle backspace
  void handleBackspace(int index) {
    if (otpControllers[index].text.isNotEmpty) {
      otpControllers[index].clear();
    } else if (index > 0) {
      otpControllers[index - 1].clear();
      focusNodes[index - 1].requestFocus();
    }
  }

  // Submit OTP
  void submitOtp() {
    String otp = otpControllers.map((e) => e.text).join();
    if (otp.length < 6) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Please enter complete OTP",
      );
      return;
    }

    verifyOtp(phone, otp);
  }

  // --------------------------------
  // API Call verify otp
  // --------------------------------

  Future<void> verifyOtp(String phone, String otp) async {
    isLoading.value = true;
    try {
      final res = await _repo.verfiyOtp(phone, otp);
      final isNewUser = res["isNewUser"] ?? false;

      CustomSnackbar.showSuccess(
        title: "Success",
        message: "OTP Verified Successfully",
      );

      // Save user to Hive
      final userJson = res["user"] ?? {
        "name": "",
        "dob": "",
        "gender": "",
        "phone": phone,
      };
      final token = res["token"] ?? "";

      final user = UserDetails(
        name: userJson["name"] ?? "",
        token: token,
        phone: userJson["phone"] ?? phone,
        email: userJson["email"] ?? "",
      );

      await HiveService.saveUser(user);

      // Navigate based on isNewUser
      if (isNewUser) {
        Get.offAllNamed(
          AppRoutes.fullName,
          arguments: phone,
        );
      } else {
        Get.offAllNamed(AppRoutes.myHome);
      }

    } catch (e) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Something went wrong. Please try again later",
      );
    } finally {
      isLoading.value = false;
    }
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';
import '../../data/network/notification_service.dart';
import '../../repo/auth_repo.dart';
import '../../utils/hive_service/hive_service.dart';
import '../../utils/hive_service/userdetail.dart';
import '../afterLogin/home_controller.dart';

class LoginController extends GetxController {
  final TextEditingController ctr = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  var isLoading = false.obs;
  var isPrivacyAccepted = false.obs;

  final _repo = AuthRepo();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
      final response = await _repo.sendOtp(ctr.text.trim());

      String successMessage = "Otp send successfully";
      if (response != null && response['debug'] != null) {
        successMessage = "OTP sent Successfully";
        print("DEBUG OTP => ${response['debug']}");
      }

      CustomSnackbar.showSuccess(
        title: "Success",
        message: successMessage,
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
  
  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    if (index == 5 && value.isNotEmpty) {
      submitOtp();
    }
  }
  
  void handleBackspace(int index) {
    if (otpControllers[index].text.isNotEmpty) {
      otpControllers[index].clear();
    } else if (index > 0) {
      otpControllers[index - 1].clear();
      focusNodes[index - 1].requestFocus();
    }
  }

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

  Future<void> verifyOtp(String phone, String otp) async {
    isLoading.value = true;
    try {
      final res = await _repo.verfiyOtp(phone, otp);
      final isNewUser = res["isNewUser"] ?? false;

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
        createdAt: DateTime.now().millisecondsSinceEpoch, // Store creation/login time
      );

      await HiveService.saveUser(user);

      // 🔥 REQUEST PERMISSION AND SYNC FCM TOKEN IMMEDIATELY AFTER LOGIN
      await NotificationService.requestPermissionAndSync();

      final userName = user.name.isNotEmpty ? user.name : "User";

      CustomSnackbar.showSuccess(
        title: "Success",
        message: "Welcome back $userName, you are logged in successfully",
      );

      if (isNewUser) {
        Get.offAllNamed(
          AppRoutes.fullName,
          arguments: phone,
        );
      } else {
        Get.offAllNamed(AppRoutes.myHome);
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.find<HomeController>().showLoginSnackbar();
        });
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

  Future<void> resendOtp() async {
    try {
      isLoading.value = true;
      final response = await _repo.sendOtp(phone);

      for (var c in otpControllers) {
        c.clear();
      }
      focusNodes[0].requestFocus();

      CustomSnackbar.showSuccess(
        title: "Success",
        message: "OTP resent successfully",
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Failed to resend OTP",
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

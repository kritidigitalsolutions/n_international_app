import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

      // Check if debug OTP is present in response
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

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      // Explicitly trigger sign out to ensure account picker appears
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDetails = UserDetails(
          name: user.displayName ?? "",
          token: await user.getIdToken() ?? "",
          phone: user.phoneNumber ?? "",
          email: user.email ?? "",
        );

        await HiveService.saveUser(userDetails);
        
        CustomSnackbar.showSuccess(
          title: "Success",
          message: "Logged in as ${user.displayName}",
        );
        
        Get.offAllNamed(AppRoutes.myHome);
      }
    } catch (e) {
      print("Detailed Google Sign-In Error: $e");
      String errorMessage = "Google Sign-In failed.";
      
      if (e.toString().contains("10")) {
        errorMessage = "Error 10: SHA-1 fingerprint mismatch. Check Firebase Console.";
      } else if (e.toString().contains("12500")) {
        errorMessage = "Error 12500: Sign-in failed. Check your internet or Google Play Services.";
      } else if (e.toString().contains("7")) {
        errorMessage = "Error 7: Network error. Please check your connection.";
      }
      
      CustomSnackbar.showError(
        title: "Sign-In Error",
        message: errorMessage,
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
  Future<void> resendOtp() async {
    try {
      isLoading.value = true;

      final response = await _repo.sendOtp(phone);

      /// Optional debug OTP
      if (response != null && response['debug'] != null) {
        print("RESEND DEBUG OTP => ${response['debug']}");
      }

      /// Clear old OTP fields
      for (var c in otpControllers) {
        c.clear();
      }

      /// Focus first field again
      focusNodes[0].requestFocus();

      CustomSnackbar.showSuccess(
        title: "Success",
        message: "OTP resent successfully",
      );
    } catch (e) {
      print("Resend Error => $e");

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

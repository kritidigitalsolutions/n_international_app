import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/network/notification_service.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/utils/hive_service/hive_service.dart';
import 'package:n_square_international/utils/hive_service/userdetail.dart';

import '../../model/request/auth_request_model/auth_req_model.dart';
import '../../repo/auth_repo.dart';
import '../../utils/custom_snakebar.dart';
import '../../viewModel/afterLogin/home_controller.dart';

class EnterFullNamePage extends StatefulWidget {
  const EnterFullNamePage({super.key});

  @override
  State<EnterFullNamePage> createState() => _EnterFullNamePageState();
}

class _EnterFullNamePageState extends State<EnterFullNamePage> {
  final TextEditingController nameController = TextEditingController();
  final RxBool isLoading = false.obs;

  void submitName() async {
    final phone = Get.arguments as String?;

    if (phone == null || phone.isEmpty) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Phone number not found. Please verify OTP again.",
      );
      return;
    }

    if (nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Please enter your full name",
      );
      return;
    }

    isLoading.value = true;

    try {
      final model = UserDetailsReqModel(
        name: nameController.text.trim(),
        phone: phone,
        email: "",
        image: "",
      );

      final response = await AuthRepo().registerUser(model);

      if (response.user != null) {
        final existingUser = HiveService.getUser();
        final updatedUser = UserDetails(
          name: response.user?.name ?? nameController.text.trim(),
          token: response.token ?? existingUser?.token ?? "",
          phone: response.user?.phone ?? phone,
          email: existingUser?.email ?? "",
          image: existingUser?.image ?? "",
        );

        await HiveService.saveUser(updatedUser);

        // 🔥 Request notification permission immediately after user creation
        await NotificationService.requestPermissionAndSync();

        // ✅ Success Snackbar
        CustomSnackbar.showSuccess(
          title: "Success",
          message: "Welcome! Your account has been created successfully.",
        );

        // Wait for user to see the snackbar
        await Future.delayed(const Duration(seconds: 2));

        Get.offAllNamed(AppRoutes.myHome);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().showLoginSnackbar();
          }
        });
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: "Registration Failed",
        message: "Something went wrong. Please try again.",
      );
      print("Registration error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Enter Full Name", style: text16()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.card,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What is your full name?",
              style: text20(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Please enter your full name as it appears on your ID.",
              style: text14(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 30),
            TextField(
              style: text15(),
              controller: nameController,
              cursorColor: AppColors.accentRed,
              decoration: InputDecoration(
                hintText: "Full Name",
                hintStyle: text14(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentRed),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Obx(() => CustomButton(
              title: "Continue",
              isLoading: isLoading.value,
              onPressed: submitName,
            )),
          ],
        ),
      ),
    );
  }
}

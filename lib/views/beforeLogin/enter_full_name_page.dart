import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/utils/hive_service/hive_service.dart';
import 'package:n_square_international/utils/hive_service/userdetail.dart';

import '../../model/request/auth_request_model/auth_req_model.dart';
import '../../repo/auth_repo.dart';

class EnterFullNamePage extends StatefulWidget {
  const EnterFullNamePage({super.key});

  @override
  State<EnterFullNamePage> createState() => _EnterFullNamePageState();
}

class _EnterFullNamePageState extends State<EnterFullNamePage> {
  final TextEditingController nameController = TextEditingController();
  final phone = Get.arguments as String;

  void submitName(String phone) async {
    final phone = Get.arguments as String?;

    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        "Error",
        "Phone number not found. Please go back and verify OTP again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check if user entered a name
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your full name",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Create request model
      final model = UserDetailsReqModel(
        name: nameController.text.trim(),
        phone: phone, // phone from OTP page
        email: "",    // blank email
        image: "",    // blank image
      );

      // Call register API
      final response = await AuthRepo().registerUser(model);
      
      if (response.user != null) {
        // Update Hive with the registered user data
        final existingUser = HiveService.getUser();
        final updatedUser = UserDetails(
          name: response.user?.name ?? nameController.text.trim(),
          token: response.token ?? existingUser?.token ?? "",
          phone: response.user?.phone ?? phone,
          email: existingUser?.email ?? "",
          image: existingUser?.image ?? "",
        );
        await HiveService.saveUser(updatedUser);
      }

      // Navigate to home page after successful registration
      Get.offAllNamed(AppRoutes.myHome);

    } catch (e) {
      Get.snackbar(
        "Error",
        "Registration failed. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      print("Registration error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Full Name", style: text16()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Get.back();
          },
        ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentRed),
                ),
              ),
            ),
            const SizedBox(height: 40),

            CustomButton(title: "Continue", onPressed: () {
              submitName(phone);
            }),
          ],
        ),
      ),
    );
  }
}

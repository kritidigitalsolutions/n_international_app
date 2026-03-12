import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

class EnterFullNamePage extends StatefulWidget {
  const EnterFullNamePage({super.key});

  @override
  State<EnterFullNamePage> createState() => _EnterFullNamePageState();
}

class _EnterFullNamePageState extends State<EnterFullNamePage> {
  final TextEditingController nameController = TextEditingController();

  void submitName() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your full name",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(AppRoutes.myHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Full Name", style: text16()),
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
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
            SizedBox(height: 40),

            CustomButton(title: "Continue", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

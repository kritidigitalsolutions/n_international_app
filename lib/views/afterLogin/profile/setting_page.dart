import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text('Settings', style: text18(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              _buildSettingsTile(
                title: 'About Us',
                onTap: () {
                  Get.toNamed(AppRoutes.aboutus);
                },
              ),

              _buildSettingsTile(
                title: 'Delete Account',
                onTap: () {
                  DeleteAccountConfirmation.show(context);
                },
              ),

              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: CustomButton(
                  textColor: AppColors.error,

                  title: "Log Out",
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: text16()),

      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      onTap: onTap,
    );
  }
}

class DeleteAccountConfirmation extends StatelessWidget {
  const DeleteAccountConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),

              // Border like your image
              border: Border.all(
                color: AppColors.white.withAlpha(50),
                width: 1,
              ),

              // Glow shadow
              // boxShadow: [
              //   BoxShadow(
              //     color: AppColors.buttonColor,
              //     blurRadius: 50, // glow softness
              //     spreadRadius: 4, // glow size
              //     offset: const Offset(0, 4),
              //   ),
              // ],
              color: AppColors.background,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Are you sure you want to permanently delete the account?',
                  textAlign: TextAlign.center,
                  style: text15(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Continue (Delete) button
                CustomButton(
                  color: AppColors.accentRed,
                  title: "Continue",
                  onPressed: () {},
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
          Positioned(
            right: 5,
            top: 2,
            child: circleIconButton(
              icon: Icons.close,
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to show this dialog from Settings screen
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DeleteAccountConfirmation(),
    );
  }
}

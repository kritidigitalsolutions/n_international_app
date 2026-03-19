import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/textStyle.dart';

import '../../../utils/hive_service/hive_service.dart';
import '../../../viewModel/afterLogin/user_controller/edit_profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({super.key});

  final controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: text18(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    /// PROFILE IMAGE WITH GLOW
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          controller.pickImageWithPermission(ImageSource.gallery);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Obx(() {
                            // 1. Show the locally picked image if available
                            if (controller.profileImage.value != null) {
                              return CircleAvatar(
                                radius: 55,
                                backgroundImage: FileImage(controller.profileImage.value!),
                              );
                            }

                            // 2. Otherwise, show the existing image from Hive/Server
                            final user = HiveService.getUser();
                            if (user != null && user.image != null && user.image!.isNotEmpty) {
                              return CircleAvatar(
                                radius: 55,
                                backgroundImage: NetworkImage(user.image!),
                              );
                            }

                            // 3. Fallback to camera icon
                            return CircleAvatar(
                              radius: 55,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 30,
                                color: AppColors.primary,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// NAME
                    _buildTextField(
                      controller: controller.nameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                      hint: "Enter your full name",
                    ),

                    const SizedBox(height: 20),

                    /// PHONE (READ ONLY)
                    _buildTextField(
                      controller: controller.mobileController,
                      label: "Phone",
                      icon: Icons.phone_android_outlined,
                      readOnly: true,
                    ),

                    const SizedBox(height: 20),

                    /// EMAIL
                    _buildTextField(
                      controller: controller.emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      hint: "Enter your email address",
                    ),

                    const SizedBox(height: 40),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 8,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: controller.editProfile,
                          child: Text(
                            "Save Changes",
                            style: text16(color: AppColors.white, fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: text14(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: text16(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: text14(color: AppColors.textSecondary.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            filled: true,
            fillColor: AppColors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

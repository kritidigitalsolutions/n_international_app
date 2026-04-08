import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_components.dart';
import '../../../viewModel/afterLogin/user_controller/full_profile_controller.dart';

class FullProfilePage extends StatelessWidget {
  const FullProfilePage({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FullProfileController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "My Profile",
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
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Initials with Glow
                    Center(
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
                          String initials = _getInitials(controller.name.value);
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Profile Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Obx(() => _buildInfoRow(Icons.person_outline, "Full Name", controller.name.value)),
                          const Divider(height: 32, color: AppColors.white, thickness: 0.1),
                          Obx(() => _buildInfoRow(Icons.phone_android_outlined, "Phone", controller.phone.value)),
                          // const Divider(height: 32, color: AppColors.white, thickness: 0.1),
                          // Obx(() => _buildInfoRow(Icons.email_outlined, "Email", controller.email.value)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // Edit Profile Button
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 56,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: AppColors.primary,
                    //       foregroundColor: AppColors.white,
                    //       elevation: 8,
                    //       shadowColor: AppColors.primary.withOpacity(0.4),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(16),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       Get.toNamed(AppRoutes.editProfile);
                    //     },
                    //     child: Text(
                    //       "Edit Profile",
                    //       style: text16(color: AppColors.white, fontWeight: FontWeight.bold),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text12(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? "Not set" : value,
                style: text16(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

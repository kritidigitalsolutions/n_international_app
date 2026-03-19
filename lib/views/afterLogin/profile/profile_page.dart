import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

import '../../../viewModel/afterLogin/user_controller/user.controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    userController.fetchUserName();
    return Scaffold(
      body: Stack(
        children: [
          backgroundGradient(),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.fullProfile);
                        },
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=68', // replace with your image
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                  Obx(() => Text(
                    'Hello\n${userController.userName.value.isEmpty ? "User" : userController.userName.value}',
                    style: text20(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                      ),
                    ],
                  ),
                ),

                // Wallet Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: decorationBox(20),
                    child: Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // recharge action
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Wallet',
                                    style: text20(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.primary,
                                    child: Center(
                                      child: Icon(
                                        Icons.wallet,
                                        color: AppColors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Available Balance',
                                    style: text15(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs 50',
                                    style: text20(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.recharge);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                  decoration: decorationBox(30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Recharge to enjoy more series',
                                        style: text13(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.download_done_outlined,
                  title: 'Offline Download',
                  onTap: () {
                    Get.toNamed(AppRoutes.offlineDownload);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'History',
                  onTap: () {
                    Get.toNamed(AppRoutes.history);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.language,
                  title: 'Language',
                  onTap: () {
                    Get.toNamed(AppRoutes.language);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,title: 'Privacy Policy',
                  onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () => Get.toNamed(AppRoutes.termsConditions),
                ),
                _buildMenuItem(
                  icon: Icons.people_alt_outlined,
                  title: 'About Us',
                  onTap: () => Get.toNamed(AppRoutes.aboutCompany),
                ),
                _buildMenuItem(
                  icon: Icons.phone_bluetooth_speaker,
                  title: 'Contact Us',
                  onTap: () => Get.toNamed(AppRoutes.contactUs),
                ),
                // _buildMenuItem(
                //   icon: Icons.settings,
                //   title: 'Settings',
                //   onTap: () {
                //     Get.toNamed(AppRoutes.setting);
                //   },
                // ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: CustomButton(
                    title: 'Logout',
                    textColor: AppColors.error,
                    onPressed: () {
                      _showLogoutDialog(context, userController);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 24),
        title: Text(title, style: text16(color: AppColors.textPrimary)),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserController userController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1A1A1A),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Logout",
                  style: text20(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to logout? You will need to login again to access your account.",
                  textAlign: TextAlign.center,
                  style: text14(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: text16(color: AppColors.textPrimary)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          userController.logout();
                        },
                        child: Text("Logout", style: text16(color: AppColors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

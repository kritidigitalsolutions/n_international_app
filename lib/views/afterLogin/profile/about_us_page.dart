import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text('About Us', style: text18(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Image.asset(AppImages.logo, height: 250),

                const SizedBox(height: 48),

                // Menu items
                _buildAboutTile(
                  title: 'Terms of Service',
                  onTap: () {
                    // Open terms page / webview / markdown
                  },
                ),

                const SizedBox(height: 4),

                _buildAboutTile(
                  title: 'Privacy Policy',
                  onTap: () {
                    // Open privacy page
                  },
                ),

                const SizedBox(height: 4),

                _buildAboutTile(
                  title: 'Version Update',

                  onTap: () {
                    // Check for updates / show changelog
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile({
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        // Border like your image
        border: Border.all(color: AppColors.white.withAlpha(50), width: 1),

        // Glow shadow
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: ListTile(
          title: Text(title, style: text15()),
          trailing:
              trailing ??
              const Icon(Icons.chevron_right, color: AppColors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

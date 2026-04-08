import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/textStyle.dart';

import '../../../data/api_responce_data.dart';
import '../../../utils/custom_button.dart';
import '../../../viewModel/afterLogin/policy_controller/policy_controller.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PolicyControllers());
    controller.fetchPrivacyPolicy();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Privacy Policy',
          style: text18(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          Obx(() {
            switch (controller.privacyPolicy.value.status) {
              case Status.loading:
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              case Status.error:
                return Center(
                  child: Text(
                    controller.privacyPolicy.value.message ?? "Error",
                    style: const TextStyle(color: AppColors.white),
                  ),
                );
              case Status.completed:
                final data = controller.privacyPolicy.value.data?.legal;
                if (data == null || data.sections == null) {
                  return const Center(
                    child: Text("No privacy policy data found", style: TextStyle(color: AppColors.white)),
                  );
                }

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Privacy Policy",
                          style: text20(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Last updated: ${data.updatedAt?.day}/${data.updatedAt?.month}/${data.updatedAt?.year}",
                          style: text14(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ...data.sections!.map((section) => _buildSection(
                          section.title ?? "",
                          section.content ?? "",
                        )),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              default:
                return const SizedBox();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text16(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: text14(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

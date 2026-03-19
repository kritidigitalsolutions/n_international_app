import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/textStyle.dart';

import '../../../data/api_responce_data.dart';
import '../../../viewModel/afterLogin/policy_controller/policy_controller.dart';

class CompanyInfoPage extends StatelessWidget {
  const CompanyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PolicyControllers());
    controller.fetchAboutUs();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'About Us',
          style: text18(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          Obx(() {
            switch (controller.aboutUs.value.status) {
              case Status.loading:
                return const Center(child: CircularProgressIndicator());
              case Status.error:
                return Center(
                  child: Text(
                    controller.aboutUs.value.message ?? "Error",
                    style: const TextStyle(color: AppColors.white),
                  ),
                );
              case Status.completed:
                final data = controller.aboutUs.value.data?.about;
                if (data == null) {
                  return const Center(child: Text("No data found", style: TextStyle(color: AppColors.white)));
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Company Logo with Glow
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withOpacity(0.05),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(AppImages.logo, height: 100),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        data.companyName ?? "",
                        style: text24(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.tagline ?? "",
                        style: text14(color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 40),

                      _buildInfoCard(
                        title: "Who We Are",
                        content: data.whoWeAre ?? "",
                      ),

                      const SizedBox(height: 20),

                      _buildInfoCard(
                        title: "Our Vision",
                        content: data.vision ?? "",
                      ),

                      const SizedBox(height: 20),

                      _buildInfoCard(
                        title: "Our Mission",
                        content: data.mission ?? "",
                      ),

                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(data.downloads ?? "0", "Downloads"),
                          _buildStatItem(data.rating ?? "0", "Rating"),
                          _buildStatItem(data.countries ?? "0", "Countries"),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      Text(
                        "Contact Us: support@nsquare.com",
                        style: text14(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 40),
                    ],
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

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text16(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: text14(color: AppColors.textSecondary,),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: text20(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: text12(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

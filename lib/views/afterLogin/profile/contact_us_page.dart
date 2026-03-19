import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api_responce_data.dart';
import '../../../viewModel/afterLogin/policy_controller/policy_controller.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Error", "Could not launch $urlString");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong while opening the link");
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PolicyControllers());
    controller.fetchContactUs();

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
          'Contact Us',
          style: text18(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          Obx(() {
            switch (controller.contactUs.value.status) {
              case Status.loading:
                return const Center(child: CircularProgressIndicator());
              case Status.error:
                return Center(
                  child: Text(
                    controller.contactUs.value.message ?? "Error",
                    style: const TextStyle(color: AppColors.white),
                  ),
                );
              case Status.completed:
                final data = controller.contactUs.value.data?.contact;
                if (data == null) {
                  return const Center(
                    child: Text("No contact data found",
                        style: TextStyle(color: AppColors.white)),
                  );
                }

                return SafeArea(
                  child: SingleChildScrollView(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Get in Touch",
                          style: text24(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We're here to help! Send us a message and we'll respond as soon as possible.",
                          style: text14(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        _buildContactCard(
                          icon: Icons.email_outlined,
                          title: "Email Us",
                          subtitle: data.email ?? "",
                          onTap: () {
                            if (data.email != null && data.email!.isNotEmpty) {
                              _launchUrl("mailto:${data.email}");
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildContactCard(
                          icon: Icons.phone_outlined,
                          title: "Call Us",
                          subtitle: data.phone ?? "",
                          onTap: () {
                            if (data.phone != null && data.phone!.isNotEmpty) {
                              _launchUrl("tel:${data.phone}");
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildContactCard(
                          icon: Icons.location_on_outlined,
                          title: "Visit Us",
                          subtitle: data.address ?? "",
                          onTap: () {
                            if (data.address != null &&
                                data.address!.isNotEmpty) {
                              final query =
                              Uri.encodeComponent(data.address!);
                              _launchUrl(
                                  "https://www.google.com/maps/search/?api=1&query=$query");
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "Our Socials",
                          style: text18(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialIcon(Icons.facebook, "Facebook",
                                data.facebook, _launchUrl),
                            _socialIcon(Icons.camera_alt_outlined, "Instagram",
                                data.instagram, _launchUrl),
                            _socialIcon(Icons.alternate_email, "Twitter",
                                data.twitter, _launchUrl),
                          ],
                        ),
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text16(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: text14(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String label, String? url,
      Future<void> Function(String) onLaunch) {
    return GestureDetector(
      onTap: () {
        if (url != null && url.isNotEmpty) {
          onLaunch(url);
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.white.withOpacity(0.05),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(label, style: text12(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

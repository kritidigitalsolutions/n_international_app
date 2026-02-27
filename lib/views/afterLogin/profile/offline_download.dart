import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

class OfflineDownloadedScreen extends StatelessWidget {
  const OfflineDownloadedScreen({super.key});

  final List<Map<String, dynamic>> downloads = const [
    {
      'title': 'Peaky Blinders',
      'subtitle': '10 episodes',
      'image': "assets/images/image1.png",
    },
    {
      'title': 'Peaky Blinders',
      'subtitle': '10 episodes',
      'image': "assets/images/image2.png",
    },
    {
      'title': 'Peaky Blinders',
      'subtitle': '10 episodes',
      'image': "assets/images/image3.png",
    },
    {
      'title': 'Peaky Blinders',
      'subtitle': '10 episodes',
      'image': "assets/images/image2.png",
    },
  ];

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
        title: Text(
          'Offline Downloaded',
          style: text18(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          final item = downloads[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: Image.asset(
                    item['image'],
                    width: 90,

                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,

                        decoration: BoxDecoration(color: AppColors.grey),
                        child: Icon(Icons.image, size: 30),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Text section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: text16(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'],
                          style: text14(color: AppColors.textSecondary),
                        ),
                        Spacer(),

                        Text(
                          "Watch now",
                          style: text13(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                // Play button
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentRed, AppColors.primary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

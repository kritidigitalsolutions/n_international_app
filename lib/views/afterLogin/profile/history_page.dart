import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, dynamic>> historyItems = const [
    {
      'title': 'Peaky Blinders',
      'subtitle': '10 episodes',
      'time': '2 days ago',
      'image': "assets/images/image2.png", // placeholder
      'isPremium': false,
    },
    {
      'title': 'Peaky Blinders',
      'subtitle': '10 episodes',
      'time': '2 days ago',
      'image': "assets/images/image1.png",
      'isPremium': false,
    },
    {
      'title': 'Peaky Blinders',
      'subtitle': '10 Premium episodes',
      'time': '2 days ago',
      'image': "assets/images/image3.png",
      'isPremium': true,
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
        title: Text('History', style: text18(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.white.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    // Image
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                          child: Image.asset(
                            item['image'],
                            width: 90,
                            // height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 90,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                ),
                                child: Icon(Icons.image, size: 30),
                              );
                            },
                          ),
                        ),

                        // Premium badge
                        if (item['isPremium'] == true)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "PREMIUM",
                                style: text11(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.background,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                            const Spacer(),
                            Text(
                              item['time'],
                              style: text12(color: AppColors.error),
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
        ],
      ),
    );
  }
}

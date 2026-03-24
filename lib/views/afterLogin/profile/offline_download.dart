import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/custom_button.dart';
import '../../../viewModel/afterLogin/download_controller/download_controller.dart';

class OfflineDownloadedScreen extends StatelessWidget {
  const OfflineDownloadedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DownloadController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: iconButton(icon: Icons.arrow_back_ios_outlined, onPressed: () => Get.back()),
        title: Text("Offline Downloads", style: text18(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          SafeArea(
            child: Obx(() {
              final downloads = controller.downloadedFiles.entries.toList();

              if (downloads.isEmpty) {
                return Center(
                  child: Text("No downloads available", style: text16(color: AppColors.textSecondary)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: downloads.length,
                itemBuilder: (context, index) {
                  final item = downloads[index];
                  final episodeId = item.key;
                  final filePath = item.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail / Placeholder
                        GestureDetector(
                          onTap: () {
                            if (File(filePath).existsSync()) {
                              Get.toNamed(AppRoutes.videoPlay, arguments: {
                                'success': true,
                                'videoPlaybackUrl': filePath,
                                'episodeId': episodeId,
                              });
                            } else {
                              Get.snackbar("Error", "File not available offline");
                            }
                          },
                          child: Container(
                            width: 90,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                bottomLeft: Radius.circular(14),
                              ),
                            ),
                            child: const Icon(Icons.movie, color: Colors.white, size: 40),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Text Section
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Episode $episodeId",
                                  style: text16(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                // Remove Button
                                GestureDetector(
                                  onTap: () async {
                                    await controller.removeDownload(episodeId);
                                  },
                                  child: Text("Remove",
                                      style: text13(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Play Button
                        GestureDetector(
                          onTap: () {
                            if (File(filePath).existsSync()) {
                              Get.toNamed(AppRoutes.videoPlay, arguments: {
                                'success': true,
                                'videoPlaybackUrl': filePath,
                                'episodeId': episodeId,
                              });
                            } else {
                              Get.snackbar("Error", "File not available offline");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.accentRed, AppColors.primary]),
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../res/app_colors.dart';
import '../../../utils/app_components.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/textStyle.dart';
import '../../../viewModel/afterLogin/history_controller/histroy_controller.dart';
import '../../../routes/app_routes.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final HistoryController controller = Get.put(HistoryController());

  String formatTime(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return "";
    }
  }

  void _showDeleteDialog(BuildContext context, String id, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Remove History",
          style: text18(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove this from your watch history?",
          style: text14(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: text14(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              controller.removeHistory(id, index);
            },
            child: Text(
              "Remove",
              style: text14(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchHistory();

    return Scaffold(
      appBar: AppBar(
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
          onPressed: () => Get.back(),
        ),
        title: Text('Watch History', style: text18(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (controller.historyList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    Text("No history found", style: text16(color: Colors.white38)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.historyList.length,
              itemBuilder: (context, index) {
                final item = controller.historyList[index];
                final title = item['series']?['title'] ?? "Untitled Series";
                final episodeTitle = item['episode']?['title'] ?? "Untitled Episode";
                final image = item['thumbnailPlaybackUrl'] ?? item['seriesPosterPlaybackUrl'] ?? "";
                final time = item['watchedAt'] != null ? formatTime(item['watchedAt']) : "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
                        child: Image.network(
                          image,
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90,
                            height: 110,
                            color: Colors.white.withOpacity(0.05),
                            child: const Icon(Icons.movie_filter_outlined, color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: text16(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text("Episode: $episodeTitle", style: text12(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 12, color: AppColors.error.withOpacity(0.6)),
                                  const SizedBox(width: 4),
                                  Text(time, style: text11(color: AppColors.error.withOpacity(0.8))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _showDeleteDialog(context, item['_id'], index),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.videoPlay,
                                  arguments: {
                                    "videoUrl": item['mediaPlaybackUrl'],
                                    "episodeId": item['episode']?['_id'],
                                    "videoId": item['series']?['_id'],
                                    "progress": item['progressSeconds'],
                                  },
                                );
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [AppColors.accentRed, AppColors.primary]),
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

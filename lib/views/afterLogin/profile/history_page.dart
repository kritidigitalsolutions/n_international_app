import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../res/app_colors.dart';
import '../../../utils/app_components.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/textStyle.dart';
import '../../../viewModel/afterLogin/history_controller/histroy_controller.dart';
import '../SeriesDetail/video_play_page.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final HistoryController controller = Get.put(HistoryController());

  String formatTime(String date) {
    final dt = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchHistory(); // ✅ API call

    return Scaffold(
      appBar: AppBar(
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
          onPressed: () => Get.back(),
        ),
        title: Text('History', style: text18(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          backgroundGradient(),

          /// ✅ OBSERVER
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.historyList.isEmpty) {
              return const Center(
                child: Text(
                  "No History Found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.historyList.length,
              itemBuilder: (context, index) {
                final item = controller.historyList[index];

                final title = item['series']?['title'] ?? "";
                final episodeTitle = item['episode']?['title'] ?? "";
                final image =
                    item['thumbnailPlaybackUrl'] ??
                        item['seriesPosterPlaybackUrl'] ??
                        "";

                final time = item['watchedAt'] != null
                    ? formatTime(item['watchedAt'])
                    : "";

                final progress = item['progressSeconds'] ?? 0;

                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.white.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          /// IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                            child: Image.network(
                              image,
                              width: 90,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90,
                                height: 110,
                                color: Colors.grey,
                                child: const Icon(Icons.image),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// TEXT
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: text16(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("Episode: $episodeTitle",
                                      style: text14(color: AppColors.textSecondary)),
                                  const Spacer(),
                                  Text("Watched: $time",
                                      style: text12(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ),

                          /// ▶ PLAY
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                final videoUrl = item['mediaPlaybackUrl'];
                                final episodeId = item['episode']?['_id'];
                                final seriesId = item['series']?['_id'];
                                final progress = item['progressSeconds'];

                                print("▶ Play clicked: $videoUrl");

                                Get.to(
                                      () => const SeriesPosterPlayerPage(),
                                  arguments: {
                                    "videoUrl": videoUrl,
                                    "episodeId": episodeId,
                                    "videoId": seriesId,
                                    "progress": progress,
                                  },
                                );
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.accentRed, AppColors.primary],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ❌ DELETE BUTTON
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          final id = item['_id'];

                          /// 👉 confirm dialog (optional but recommended)
                          Get.defaultDialog(
                            title: "Delete",
                            middleText: "Remove from history?",
                            textConfirm: "Yes",
                            textCancel: "No",
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.back();

                              controller.removeHistory(id, index);
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

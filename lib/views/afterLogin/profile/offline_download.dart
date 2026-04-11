import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../../../model/responce/audio_res_model/song_res_model.dart';
import '../../../model/responce/series_res_model/episode_res_model.dart';
import '../../../model/responce/series_res_model/series_res_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/custom_button.dart';
import '../../../viewModel/afterLogin/download_controller/download_controller.dart';

class OfflineDownloadedScreen extends StatefulWidget {
  const OfflineDownloadedScreen({super.key});

  @override
  State<OfflineDownloadedScreen> createState() => _OfflineDownloadedScreenState();
}

class _OfflineDownloadedScreenState extends State<OfflineDownloadedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.put(DownloadController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: iconButton(
            icon: Icons.arrow_back_ios_outlined, onPressed: () => Get.back()),
        title: Text("Offline Downloads", style: text18(
            fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(),
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: AppColors.error,
              unselectedLabelColor: AppColors.white,
              labelStyle: text16(fontWeight: FontWeight.bold),
              unselectedLabelStyle: text16(),
              tabs: const [
                Tab(text: "Series"),
                Tab(text: "Songs"),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDownloadList("EPISODE"),
                _buildDownloadList("SONG"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadList(String contentType) {
    return Obx(() {
      final downloads = controller.downloadedMeta.values
          .where((item) => item["contentType"] == contentType)
          .toList();

      if (downloads.isEmpty) {
        return Center(
          child: Text(
            "No ${contentType == "EPISODE"
                ? "series"
                : "songs"} available offline",
            style: text16(color: AppColors.textSecondary),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          final meta = downloads[index];

          final id = meta["id"];
          final filePath = meta["filePath"];
          final title = meta["title"];
          final subtitle = meta["subtitle"] ?? "";
          final image = meta["image"];

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
                GestureDetector(
                  onTap: () => _playItem(contentType, filePath, id, meta),
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
                    child: image != null
                        ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                      child: image.startsWith('http') 
                        ? Image.network(image, width: 90, height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white))
                        : Image.file(File(image), width: 90, height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white)),
                    )
                        : Icon(contentType == "EPISODE" ? Icons.movie : Icons.music_note, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text16(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: text12(color: AppColors.textSecondary),
                          maxLines: 1,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async => await controller.removeDownload(id),
                          child: Text("Remove", style: text13(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _playItem(contentType, filePath, id, meta),
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
    });
  }

  void _playItem(String contentType, String filePath, String id, dynamic meta) {
    if (filePath.isEmpty || !File(filePath).existsSync()) {
      Get.snackbar("Error", "File not found on device", snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.accentRed, colorText: Colors.white);
      return;
    }

    if (contentType == "EPISODE") {
      final episode = Episode(
        id: id,
        title: meta["title"] ?? "Offline Episode",
        videoUrl: filePath,
        description: meta["subtitle"] ?? "",
        thumbnail: meta["image"],
        alreadyUnlocked: true,
      );

      Get.toNamed(
        AppRoutes.videoPlay,
        arguments: {
          'episodes': [episode],
          'initialIndex': 0,
          'series': Series(sId: meta["seriesId"], title: meta["title"]),
          'isOffline': true,
        },
      );
    } else if (contentType == "SONG") {
      final songData = meta["song"];
      final song = Song(
        id: songData?["_id"] ?? id,
        title: songData?["title"] ?? meta["title"],
        thumbnail: songData?["thumbnail"] ?? meta["image"],
      );

      Get.toNamed(
        AppRoutes.musicPlay,
        arguments: {
          "song": song,
          "filePath": filePath,
        },
      );
    }
  }
}

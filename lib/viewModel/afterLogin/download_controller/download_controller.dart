import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/api_responce_data.dart';
import '../../../model/responce/download_res_model/download_res_model.dart';
import '../../../repo/donwload_repo.dart';

class DownloadController extends GetxController {
  final DownloadRepo _repo = DownloadRepo();
  final Dio dio = Dio();

  var downloadingIds = <String>[].obs;

  // RxMap to track episodeId -> local file path
  var downloadedFiles = <String, String>{}.obs;

  var downloadListResponse = ApiResponse<DownloadResModel>.loading().obs;
  var isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDownloads();
  }

  /// Fetch downloads from API
  Future<void> fetchDownloads() async {
    downloadListResponse.value = ApiResponse.loading();
    try {
      final data = await _repo.getOfflineDownloads();
      downloadListResponse.value = ApiResponse.completed(data);

      // Populate downloadedFiles if file exists locally
      if (data.downloads != null) {
        for (var item in data.downloads!) {
          final episodeId = item.episode?.sId ?? item.sId;

          // Skip if episodeId is null
          if (episodeId == null) continue;

          final fileName = "$episodeId.mp4";
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String filePath = "${appDocDir.path}/$fileName";

          if (File(filePath).existsSync()) {
            downloadedFiles[episodeId] = filePath; // ✅ now both non-null
          }
        }
    }
    } catch (e) {
      downloadListResponse.value = ApiResponse.error(e.toString());
    }
  }

  /// Start download: API + file download
  Future<void> startDownload({
    required String seriesId,
    required String episodeId,
    required String downloadUrl,
  }) async {
    if (downloadingIds.contains(episodeId)) return;

    try {
      downloadingIds.add(episodeId);

      // 1️⃣ API call to mark download
      final response = await _repo.addOfflineDownload(seriesId: seriesId, episodeId: episodeId);
      if (response['success'] != true) {
        Get.snackbar("Error", response['message'] ?? "Failed to add download",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return;
      }

      // 2️⃣ Actual file download
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = "${appDocDir.path}/$episodeId.mp4";

      await dio.download(downloadUrl, savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print("Downloading $episodeId: ${(received / total * 100).toStringAsFixed(0)}%");
            }
          });

      // 3️⃣ Update reactive map
      downloadedFiles[episodeId] = savePath;

      Get.snackbar("Success", "Download complete",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Download failed",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      downloadingIds.remove(episodeId);
    }
  }

  /// Remove download (local + backend)
  Future<void> removeDownload(String episodeId) async {
    try {
      isDeleting.value = true;

      // Remove local file
      if (downloadedFiles.containsKey(episodeId)) {
        final file = File(downloadedFiles[episodeId]!);
        if (file.existsSync()) file.deleteSync();
        downloadedFiles.remove(episodeId);
      }

      // Optional: remove from backend
      await _repo.deleteDownload(episodeId);

      Get.snackbar("Removed", "Download removed",
          backgroundColor: Colors.green.withOpacity(0.7), colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to remove download");
    } finally {
      isDeleting.value = false;
    }
  }

  /// Check if episode is downloaded
  bool isDownloaded(String episodeId) {
    return downloadedFiles.containsKey(episodeId) && File(downloadedFiles[episodeId]!).existsSync();
  }
}

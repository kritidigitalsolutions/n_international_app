import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadController extends GetxController {
  final Dio dio = Dio();

  var downloadingIds = <String>[].obs;
  
  /// id -> percentage (0 to 100)
  var downloadProgress = <String, double>{}.obs;

  /// id -> file path
  var downloadedFiles = <String, String>{}.obs;

  /// id -> metadata
  var downloadedMeta = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDownloads();
  }

  /// ============================
  /// FETCH LOCAL DOWNLOADS
  /// ============================
  Future<void> fetchDownloads() async {
    print("FETCH CALLED");
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList("offline_data") ?? [];
    print("LOCAL DATA: $savedList");

    downloadedFiles.clear();
    downloadedMeta.clear();

    for (var item in savedList) {
      final data = jsonDecode(item);

      final filePath = data["filePath"];
      final id = data["id"];

      if (File(filePath).existsSync()) {
        downloadedFiles[id] = filePath;
        downloadedMeta[id] = data;
      }
    }
  }

  /// ============================
  /// CHECK DOWNLOADED
  /// ============================
  bool isDownloaded(String id) {
    return downloadedFiles.containsKey(id) &&
        File(downloadedFiles[id]!).existsSync();
  }

  /// ============================
  /// DOWNLOAD + SAVE LOCAL
  /// ============================
  Future<void> startDownload({
    String? seriesId,
    String? episodeId,
    String? songId,
    required String contentType,
    required String downloadUrl,
    required String title,
    String? image,
    String? subtitle,
  }) async {
    final id = episodeId ?? songId;
    if (id == null) return;

    if (isDownloaded(id)) {
      Get.snackbar("Already Downloaded", "Already available offline",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (downloadingIds.contains(id)) return;

    try {
      downloadingIds.add(id);
      downloadProgress[id] = 0.0;

      /// FILE SAVE PATH
      Directory dir = await getApplicationDocumentsDirectory();

      /// DOWNLOAD IMAGE LOCALLY
      String? localImagePath;
      if (image != null && image.isNotEmpty) {
        try {
          final imageExt = image.split('.').last.split('?').first;
          localImagePath = "${dir.path}/${id}_thumb.${imageExt.length > 4 ? 'jpg' : imageExt}";
          await dio.download(image, localImagePath);
          debugPrint("Image Downloaded: $localImagePath");
        } catch (e) {
          debugPrint("Image Download Error: $e");
        }
      }

      final extension = contentType == "SONG" ? "mp3" : "mp4";
      String path = "${dir.path}/$id.$extension";

      /// DOWNLOAD FILE
      await dio.download(
        downloadUrl,
        path,
        onReceiveProgress: (rec, total) {
          if (total != -1) {
            double progress = (rec / total);
            downloadProgress[id] = progress;
            debugPrint("Downloading $id: ${(progress * 100).toStringAsFixed(0)}%");
          }
        },
      );

      /// SAVE METADATA LOCALLY
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList("offline_data") ?? [];

      final newItem = {
        "id": id,
        "title": title,
        "filePath": path,
        "contentType": contentType,
        "image": localImagePath ?? image, // Save local path if download successful
        "subtitle": subtitle,
        "episodeId": episodeId,
        "seriesId": seriesId,

        // ✅ ADD THIS (VERY IMPORTANT)
        "song": {
          "_id": songId,
          "title": title,
          "thumbnail": localImagePath ?? image,
        }
      };


      savedList.add(jsonEncode(newItem));
      await prefs.setStringList("offline_data", savedList);

      /// REFRESH UI
      await fetchDownloads();

      print("SAVING DOWNLOAD: $newItem");
      Get.snackbar("Success", "Download completed",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint("Download Error: $e");
      Get.snackbar("Error", "Download failed",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      downloadingIds.remove(id);
      downloadProgress.remove(id);
    }
  }

  /// ============================
  /// REMOVE DOWNLOAD
  /// ============================
  Future<void> removeDownload(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList("offline_data") ?? [];

      /// REMOVE FROM LIST
      savedList.removeWhere((item) {
        final data = jsonDecode(item);
        return data["id"] == id;
      });

      await prefs.setStringList("offline_data", savedList);

      /// DELETE FILE
      if (downloadedFiles.containsKey(id)) {
        final file = File(downloadedFiles[id]!);
        if (file.existsSync()) file.deleteSync();

        // Delete local image if exists
        final meta = downloadedMeta[id];
        if (meta != null && meta["image"] != null) {
          final imagePath = meta["image"];
          if (imagePath != null && !imagePath.startsWith("http")) {
            final imageFile = File(imagePath);
            if (imageFile.existsSync()) imageFile.deleteSync();
          }
        }
      }

      downloadedFiles.remove(id);
      downloadedMeta.remove(id);

      Get.snackbar("Removed", "Download removed",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint("Remove Error: $e");
      Get.snackbar("Error", "Failed to remove");
    }
  }
}

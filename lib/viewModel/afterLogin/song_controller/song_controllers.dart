import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SongListController extends GetxController {
  final RxInt _index = 0.obs;
  RxInt get index => _index;

  void toggle(int index) {
    _index.value = index;
  }

  var selectedTab = 0.obs; // 0: Popular, 1: Trending, etc.

  final List<Map<String, dynamic>> songs = List.generate(
    15,
    (index) => {
      'title': 'Husn',
      'artist': 'Anuv Jain',
      'imageUrl':
          'https://i.ytimg.com/vi/gJLVTKhTnog/maxresdefault.jpg', // real Husn thumbnail from YouTube
    },
  );

  void changeTab(int index) {
    selectedTab.value = index;
    // In real app: fetch different data based on tab
  }

  void showMoreOptions(int index) {
    Get.bottomSheet(
      Container(
        color: const Color(0xFF1A1A1A),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text(
                'Add to Playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text(
                'Download',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_responce_data.dart';
import '../../../model/responce/audio_res_model/playlist_res_model.dart';
import '../../../model/responce/audio_res_model/song_play_res_model.dart';
import '../../../model/responce/audio_res_model/song_res_model.dart';
import '../../../model/responce/song_res_model/song_res_model.dart';
import '../../../repo/audio_repo.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/custom_snakebar.dart';
import '../favorite_controller.dart';

class SongListController extends GetxController {
  final AudioRepo _repo = AudioRepo();
  final RxInt _index = 0.obs;
  RxInt get index => _index;
  var favoriteMap = <String, bool>{}.obs;

  void toggle(int index) {
    _index.value = index;
    if (index == 1) {
      fetchPlaylist();
    } else {
      filterSongs();
    }
  }

  var isPlaybackLoading = false.obs;
  var selectedTab = 0.obs; // 0: Popular, 1: Trending, 2: Top Charts, 3: New Releases
  final List<String> languages = ['English', 'Hindi', 'Punjabi', 'Spanish'];
  var selectedLanguage = 'English'.obs;

  var songResponse = ApiResponse<SongResModel>.loading().obs;
  var allSongs = <Song>[].obs;
  var displaySongs = <Song>[].obs;

  var playlistResponse = ApiResponse<PlaylistResModel>.loading().obs;
  var rawPlaylist = <Song>[].obs;
  var displayPlaylist = <Song>[].obs;

  var favoriteSongResponse = ApiResponse<FavoriteSongResModel>.loading().obs;
  var favoriteSongs = <FavoriteSong>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSongs();
    fetchFavoriteSong();
  }

  void fetchSongs() async {
    songResponse.value = ApiResponse.loading();
    try {
      final response = await _repo.getSongs();
      songResponse.value = ApiResponse.completed(response);
      allSongs.assignAll(response.songs ?? []);
      filterSongs();
    } catch (e) {
      songResponse.value = ApiResponse.error(e.toString());
    }
  }

  void fetchPlaylist() async {
    playlistResponse.value = ApiResponse.loading();
    try {
      final response = await _repo.getPlaylist();
      playlistResponse.value = ApiResponse.completed(response);
      rawPlaylist.assignAll(response.playlist ?? []);
      filterSongs();
    } catch (e) {
      playlistResponse.value = ApiResponse.error(e.toString());
    }
  }

  void addToPlaylist(String songId) async {
    try {
      final res = await _repo.addToPlaylist(songId);
      if (res['success'] == true) {
        CustomSnackbar.showSuccess(title: "Success", message: "Added to playlist");
        if (index.value == 1) fetchPlaylist();
      }
    } catch (e) {
      CustomSnackbar.showError(title: "Error", message: "Failed to add to playlist");
    }
  }

  void removeFromPlaylist(String songId) async {
    try {
      final res = await _repo.removeFromPlaylist(songId);
      if (res['success'] == true) {
        CustomSnackbar.showSuccess(title: "Success", message: "Removed from playlist");
        fetchPlaylist();
      }
    } catch (e) {
      CustomSnackbar.showError(title: "Error", message: "Failed to remove from playlist");
    }
  }
  /// --------------------------------
  // favourite song
  /// --------------------------------

  void fetchFavoriteSong() async {
    favoriteSongResponse.value = ApiResponse.loading();
    try {
      final response = await _repo.fetchFavoritesSong();
      favoriteSongResponse.value = ApiResponse.completed(response);
      favoriteSongs.assignAll(response.favorites ?? []);
      /// ✅ Sync favoriteMap
      for (var song in favoriteSongs) {
        if (song.id != null) {
          favoriteMap[song.id!] = true;
        }
      }
    } catch (e) {
      favoriteSongResponse.value = ApiResponse.error(e.toString());
    }
  }
/// song play
  void playSong(String songId) async {
    try {
      isPlaybackLoading.value = true;

      final response = await _repo.getSongPlayData(songId);

      if (response.success == true && response.playData != null) {
        final data = response.playData!;

        String finalAudioUrl =
            data.audioPlaybackUrl ?? data.audioUrl ?? "";

        String finalThumbUrl =
            data.thumbnailPlaybackUrl ?? data.thumbnailUrl ?? "";

        if (finalAudioUrl.isNotEmpty) {
          Get.toNamed(
            AppRoutes.musicPlay,
            arguments: {
              'id': data.id,
              'url': finalAudioUrl,
              'title': data.title,
              'artist': data.artist,
              'image': finalThumbUrl,
            },
          );
        } else {
          CustomSnackbar.showError(
              title: "Error", message: "Audio file not found");
        }
      }
    } catch (e) {
      print("Playback Error: $e");
      CustomSnackbar.showError(
          title: "Error", message: "Failed to load song playback");
    } finally {
      isPlaybackLoading.value = false;
    }
  }

// Check if this series is already in favorites when page opens
  void toggleFavorite(String songid) async {
    try {
      final isFav = favoriteMap[songid] ?? false;

      if (isFav) {
        final res = await _repo.deleteFavoriteSong(songid);

        if (res['success'] == true) {
          favoriteMap[songid] = false;

          /// remove from local list
          favoriteSongs.removeWhere((e) => e.id == songid);

          CustomSnackbar.showSuccess(
            title: "Removed",
            message: "Removed from favorites",
          );
        }
      } else {
        final res = await _repo.addFavoriteSong(songid);
        if (res['success'] == true) {
          favoriteMap[songid] = true;
          CustomSnackbar.showSuccess(
            title: "Added",
            message: "Added to favorites",
          );
          /// optional: refresh
          fetchFavoriteSong();
        }
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }
  /// favourite
  void filterSongs() {
    if (index.value == 0) {
      // Filter Songs
      if (allSongs.isEmpty) return;
      List<Song> filtered = _applyFilter(allSongs);
      displaySongs.assignAll(filtered);
    } else {
      // Filter Playlist
      if (rawPlaylist.isEmpty) {
        displayPlaylist.clear();
        return;
      }
      List<Song> filtered = _applyFilter(rawPlaylist);
      displayPlaylist.assignAll(filtered);
    }
  }

  List<Song> _applyFilter(List<Song> source) {
    switch (selectedTab.value) {
      case 0:
        return source.where((s) => s.isPopular ?? false).toList();
      case 1:
        return source.where((s) => s.isTrending ?? false).toList();
      case 2:
        return source.where((s) => s.isTopChart ?? false).toList();
      case 3:
        return source.where((s) => s.isNewRelease ?? false).toList();
      default:
        return source;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    filterSongs();
  }

  void changeLanguage(String lang) {
    selectedLanguage.value = lang;
  }

  void showMoreOptions(int listIndex, {bool isPlaylist = false}) {
    final song = isPlaylist ? displayPlaylist[listIndex] : displaySongs[listIndex];
    
    Get.bottomSheet(
      Container(
        color: const Color(0xFF1A1A1A),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(isPlaylist ? Icons.playlist_remove : Icons.playlist_add, color: Colors.white),
              title: Text(isPlaylist ? 'Remove from Playlist' : 'Add to Playlist', style: const TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                if (song.id != null) {
                  if (isPlaylist) {
                    removeFromPlaylist(song.id!);
                  } else {
                    addToPlaylist(song.id!);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text('Download', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

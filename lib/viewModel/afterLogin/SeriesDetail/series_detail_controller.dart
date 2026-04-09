import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_responce_data.dart';
import '../../../model/responce/series_res_model/episode_res_model.dart';
import '../../../model/responce/series_res_model/play_episode_res_model.dart';
import '../../../repo/series_repo.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/custom_snakebar.dart';
import '../favorite_controller.dart';
import '../user_controller/full_profile_controller.dart';

class SeriesDetailController extends GetxController {
  final SeriesRepo _repo = SeriesRepo();

  var episodesResponse = ApiResponse<EpisodeResModel>.loading().obs;
  var playEpisodeResponse = ApiResponse<PlayEpisodeResModel>.loading().obs;
  var isFavorite = false.obs;
  var isFavoriteLoading = false.obs;
  var isUnlocking = false.obs;
  var isInitialLoading = true.obs;

  // Track locally unlocked episodes
  var locallyUnlockedIds = <String>{}.obs;

  // Episode Like state
  var isLiked = false.obs;
  var likesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUnlockedEpisodes();
  }

  Future<void> _loadUnlockedEpisodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList("unlocked_episodes") ?? [];
      locallyUnlockedIds.assignAll(list);
    } catch (e) {
      print("Error loading unlocked episodes: $e");
    }
  }

  Future<void> _saveUnlockedEpisode(String episodeId) async {
    if (!locallyUnlockedIds.contains(episodeId)) {
      locallyUnlockedIds.add(episodeId);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList("unlocked_episodes", locallyUnlockedIds.toList());
      } catch (e) {
        print("Error saving unlocked episode: $e");
      }
    }
  }

  void fetchEpisodes(String seriesId) async {
    isInitialLoading.value = true;
    try {
      await _loadUnlockedEpisodes();
      final response = await _repo.fetchEpisodes(seriesId);

      if (response.episodes != null) {
        for (var episode in response.episodes!) {
          if (episode.id != null &&
              (locallyUnlockedIds.contains(episode.id) ||
                  episode.alreadyUnlocked == true)) {
            episode.alreadyUnlocked = true;
          } else {
            episode.alreadyUnlocked = false;
          }
        }
      }
      episodesResponse.value = ApiResponse.completed(response);
    } catch (e) {
      episodesResponse.value = ApiResponse.error(e.toString());
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> unlockEpisode(String seriesId, String episodeId) async {
    final profileController = Get.find<FullProfileController>();

    if (profileController.walletBalance.value < 1) {
      CustomSnackbar.showError(title: "Insufficient Balance", message: "You need at least 1 rupee to unlock this episode.");
      return;
    }

    isUnlocking.value = true;
    try {
      final response = await _repo.unlockEpisode(episodeId);
      if (response['success'] == true) {
        CustomSnackbar.showSuccess(title: "Success", message: "Episode unlocked successfully!");

        // Update wallet balance immediately from response using safer parsing
        dynamic newBalanceRaw;
        if (response['unlock'] != null && response['unlock']['walletBalance'] != null) {
          newBalanceRaw = response['unlock']['walletBalance'];
        } else if (response['walletBalance'] != null) {
          newBalanceRaw = response['walletBalance'];
        }

        if (newBalanceRaw != null) {
          // Use num.parse().toInt() to handle doubles like 9.0
          profileController.walletBalance.value = num.parse(newBalanceRaw.toString()).toInt();
        }
        
        // 🔥 Refresh profile to ensure total sync
        await profileController.fetchUserProfile();

        // Persist unlock status locally
        await _saveUnlockedEpisode(episodeId);

        // Update local episode list state
        if (episodesResponse.value.data != null && episodesResponse.value.data!.episodes != null) {
          final episodeIndex = episodesResponse.value.data!.episodes!.indexWhere((e) => e.id == episodeId);
          if (episodeIndex != -1) {
            episodesResponse.value.data!.episodes![episodeIndex].alreadyUnlocked = true;
            episodesResponse.refresh();
          }
        }
        
        // Re-fetch to ensure server state is in sync
        fetchEpisodes(seriesId);

      } else {
        CustomSnackbar.showError(title: "Error", message: response['message'] ?? "Failed to unlock episode");
      }
    } catch (e) {
      print("Unlock Error: $e");
      CustomSnackbar.showError(title: "Error", message: "An error occurred during unlock.");
    } finally {
      isUnlocking.value = false;
    }
  }

  void checkIsFavorite(String seriesId) async {
    try {
      final res = await _repo.fetchFavorites();
      if (res.items != null) {
        isFavorite.value = res.items!.any((item) => item.series?.sId == seriesId);
      }
    } catch (e) {
      print("Error checking favorite status: $e");
    }
  }

  void toggleFavorite(String seriesId) async {
    try {
      isFavoriteLoading.value = true;
      if (isFavorite.value) {
        final res = await _repo.deleteFavorite(seriesId);
        if (res['success'] == true) {
          isFavorite.value = false;
          CustomSnackbar.showSuccess(title: "Success", message: "Removed from favorites");
          if (Get.isRegistered<FavoriteController>()) {
            Get.find<FavoriteController>().fetchFavorites();
          }
        }
      } else {
        final res = await _repo.addFavorite(seriesId);
        if (res['success'] == true) {
          isFavorite.value = true;
          CustomSnackbar.showSuccess(title: "Success", message: "Added to favorites");
          if (Get.isRegistered<FavoriteController>()) {
            Get.find<FavoriteController>().fetchFavorites();
          }
        }
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  Future<void> getEpisodeLikeStatus(String episodeId) async {
    try {
      final response = await _repo.getLikeStatus(episodeId);
      if (response['success'] == true && response['like'] != null) {
        isLiked.value = response['like']['liked'] ?? false;
        likesCount.value = response['like']['likesCount'] ?? 0;
      }
    } catch (e) {
      print("Error fetching like status: $e");
    }
  }

  Future<void> toggleEpisodeLike(String episodeId) async {
    try {
      if (isLiked.value) {
        final response = await _repo.dislikeEpisode(episodeId);
        if (response['success'] == true) {
          isLiked.value = false;
          if (response['likesCount'] != null) {
            likesCount.value = response['likesCount'];
          } else {
            likesCount.value--;
          }
        }
      } else {
        final response = await _repo.likeEpisode(episodeId);
        if (response['success'] == true) {
          isLiked.value = true;
          if (response['likesCount'] != null) {
            likesCount.value = response['likesCount'];
          } else {
            likesCount.value++;
          }
        }
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }
}

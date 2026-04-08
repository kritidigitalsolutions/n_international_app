import 'package:get/get.dart';
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

  // Track locally unlocked episodes
  var locallyUnlockedIds = <String>{}.obs;

  // Episode Like state
  var isLiked = false.obs;
  var likesCount = 0.obs;

  void fetchEpisodes(String seriesId) async {
    if (episodesResponse.value.data == null) {
      episodesResponse.value = ApiResponse.loading();
    }

    try {
      final response = await _repo.fetchEpisodes(seriesId);

      // Initialize episodes list
      episodesResponse.value = ApiResponse.completed(response);

      // Fetch status for each episode as soon as possible
      if (response.episodes != null) {
        _checkAllEpisodesUnlockStatus(response.episodes!);
      }
    } catch (e) {
      if (episodesResponse.value.data == null) {
        episodesResponse.value = ApiResponse.error(e.toString());
      }
    }
  }

  // Optimized method to update UI as soon as each episode status is received
  Future<void> _checkAllEpisodesUnlockStatus(List<Episode> episodes) async {
    final futures = episodes.map((episode) async {
      try {
        final playData = await _repo.playEpisode(episode.id!);
        // Use alreadyUnlocked from the play API response
        episode.alreadyUnlocked = playData.alreadyUnlocked;

        if (episode.alreadyUnlocked == true) {
          locallyUnlockedIds.add(episode.id!);
        }
      } catch (e) {
        // If play API fails or returns error, we assume it's locked
        episode.alreadyUnlocked = false;
      }
    }).toList();

    await Future.wait(futures);
    episodesResponse.refresh(); // Trigger UI update once status is fetched
  }

  // Check if this series is already in favorites
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


  Future<void> playEpisode(String episodeId) async {
    playEpisodeResponse.value = ApiResponse.loading();
    try {
      final data = await _repo.playEpisode(episodeId);
      playEpisodeResponse.value = ApiResponse.completed(data);
      Get.toNamed(AppRoutes.videoPlay, arguments: data);
    } catch (e) {
      playEpisodeResponse.value = ApiResponse.error(e.toString());
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

        // Update wallet balance
        var newBalance = 0;
        if (response['unlock'] != null && response['unlock']['walletBalance'] != null) {
          newBalance = response['unlock']['walletBalance'];
        } else if (response['walletBalance'] != null) {
          newBalance = response['walletBalance'];
        }

        if (newBalance > 0) {
          profileController.walletBalance.value = newBalance;
        } else {
          profileController.fetchUserProfile();
        }

        // Add to local unlocked set
        locallyUnlockedIds.add(episodeId);

        // Update local state immediately
        if (episodesResponse.value.data != null && episodesResponse.value.data!.episodes != null) {
          final episodeIndex = episodesResponse.value.data!.episodes!.indexWhere((e) => e.id == episodeId);
          if (episodeIndex != -1) {
            episodesResponse.value.data!.episodes![episodeIndex].alreadyUnlocked = true;
            episodesResponse.refresh();
          }
        }

        // Refresh status using play API to ensure everything is in sync
        fetchEpisodes(seriesId);

      } else {
        CustomSnackbar.showError(title: "Error", message: response['message'] ?? "Failed to unlock episode");
      }
    } catch (e) {
      CustomSnackbar.showError(title: "Error", message: e.toString());
    } finally {
      isUnlocking.value = false;
    }
  }

  // --- Episode Like Methods ---

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

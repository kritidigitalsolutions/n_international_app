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
    // Start loading local data immediately
    _loadUnlockedEpisodes();
  }

  Future<void> _loadUnlockedEpisodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList("unlocked_episodes") ?? [];
      locallyUnlockedIds.addAll(list);
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

          /// ✅ ONLY per episode check
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

  // Future<void> _checkAllEpisodesUnlockStatus(List<Episode> episodes) async {
  //   for (var episode in episodes) {
  //     // If already marked as unlocked, skip network check
  //     if (episode.id == null ||
  //         episode.isLocked == false ||
  //         episode.alreadyUnlocked == true ||
  //         locallyUnlockedIds.contains(episode.id)) {
  //
  //       // Sync local cache if server says it's unlocked but we don't have it
  //       if ((episode.isLocked == false || episode.alreadyUnlocked == true) && episode.id != null) {
  //         _saveUnlockedEpisode(episode.id!);
  //       }
  //       continue;
  //     }
  //
  //     // Check server for current status
  //     _repo.playEpisode(episode.id!).then((playData) {
  //       if (playData.alreadyUnlocked == true) {
  //         episode.alreadyUnlocked = true;
  //         _saveUnlockedEpisode(episode.id!);
  //         episodesResponse.refresh(); // Trigger UI update
  //       }
  //     }).catchError((e) {
  //       // Silent error for background check
  //     });
  //   }
  // }

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

        // Persist unlock status
        await _saveUnlockedEpisode(episodeId);

        // Update local state immediately
        if (episodesResponse.value.data != null && episodesResponse.value.data!.episodes != null) {
          final episodeIndex = episodesResponse.value.data!.episodes!.indexWhere((e) => e.id == episodeId);
          if (episodeIndex != -1) {
            episodesResponse.value.data!.episodes![episodeIndex].alreadyUnlocked = true;
            episodesResponse.refresh();
          }
        }

        // Refresh series data
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

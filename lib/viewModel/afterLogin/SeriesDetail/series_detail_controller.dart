import 'package:get/get.dart';
import '../../../data/api_responce_data.dart';
import '../../../model/responce/series_res_model/episode_res_model.dart';
import '../../../model/responce/series_res_model/play_episode_res_model.dart';
import '../../../repo/series_repo.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/custom_snakebar.dart';
import '../favorite_controller.dart';

class SeriesDetailController extends GetxController {
  final SeriesRepo _repo = SeriesRepo();

  var episodesResponse = ApiResponse<EpisodeResModel>.loading().obs;
  var playEpisodeResponse = ApiResponse<PlayEpisodeResModel>.loading().obs;
  var isFavorite = false.obs;

  void fetchEpisodes(String seriesId) async {
    episodesResponse.value = ApiResponse.loading();
    try {
      final response = await _repo.fetchEpisodes(seriesId);
      episodesResponse.value = ApiResponse.completed(response);
    } catch (e) {
      episodesResponse.value = ApiResponse.error(e.toString());
    }
  }

  // Check if this series is already in favorites when page opens
  void checkIsFavorite(String seriesId) async {
    try {
      final res = await _repo.fetchFavorites();
      if (res.items != null) {
        // Check if any favorite item has this series ID
        isFavorite.value = res.items!.any((item) => item.series?.sId == seriesId);
      }
    } catch (e) {
      print("Error checking favorite status: $e");
    }
  }

  void toggleFavorite(String seriesId) async {
    try {
      if (isFavorite.value) {
        final res = await _repo.deleteFavorite(seriesId);
        if (res['success'] == true) {
          isFavorite.value = false;
          CustomSnackbar.showSuccess(title: "Success", message: "Removed from favorites");
          
          // Refresh Favorite list immediately
          if (Get.isRegistered<FavoriteController>()) {
            Get.find<FavoriteController>().fetchFavorites();
          }
        }
      } else {
        final res = await _repo.addFavorite(seriesId);
        if (res['success'] == true) {
          isFavorite.value = true;
          CustomSnackbar.showSuccess(title: "Success", message: "Added to favorites");
          
          // Refresh Favorite list immediately
          if (Get.isRegistered<FavoriteController>()) {
            Get.find<FavoriteController>().fetchFavorites();
          }
        }
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }


  Future<void> playEpisode(String episodeId) async {
    playEpisodeResponse.value = ApiResponse.loading();

    try {
      final data = await _repo.playEpisode(episodeId);

      playEpisodeResponse.value = ApiResponse.completed(data);

      /// Navigate to player page with API data
      Get.toNamed(
        AppRoutes.videoPlay,
        arguments: data,
      );

    } catch (e) {
      playEpisodeResponse.value = ApiResponse.error(e.toString());
    }
  }
}

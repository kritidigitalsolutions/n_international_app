import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/model/responce/series_res_model/favorite_res_model.dart';
import 'package:n_square_international/repo/series_repo.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';

class FavoriteController extends GetxController {
  final SeriesRepo _repo = SeriesRepo();
  
  var favoriteResponse = ApiResponse<FavoriteResModel>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    favoriteResponse.value = ApiResponse.loading();
    try {
      final response = await _repo.fetchFavorites();
      favoriteResponse.value = ApiResponse.completed(response);
    } catch (e) {
      favoriteResponse.value = ApiResponse.error(e.toString());
    }
  }

  Future<void> removeFromFavorite(String seriesId) async {
    try {
      final response = await _repo.deleteFavorite(seriesId);
      if (response['success'] == true) {
        CustomSnackbar.showSuccess(title: 'Success', message: 'Removed from favorites');
        fetchFavorites(); // Refresh list
      }
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: 'Failed to remove from favorites');
    }
  }
}

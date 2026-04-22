import '../data/network/api_network_service.dart';
import '../model/responce/language_res_model.dart';
import '../model/responce/series_res_model/episode_res_model.dart';
import '../model/responce/series_res_model/favorite_res_model.dart';
import '../model/responce/series_res_model/play_episode_res_model.dart';
import '../model/responce/series_res_model/series_res_model.dart';
import '../res/app_url.dart';
import '../utils/hive_service/hive_service.dart';

class SeriesRepo {
  final _api = NetworkApiService();

  Future<LanguageResModel> fetchLanguages() async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.getApi(AppUrls.languages);
      return LanguageResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<SeriesResModel> fetchSeries({int page = 1, int limit = 20, String? search}) async {
    try {
      final token = HiveService.getToken();
      _api.setToken(token!);
      
      String url = "${AppUrls.seriesList}?page=$page&limit=$limit";
      if (search != null && search.isNotEmpty) {
        url += "&search=$search";
      }
      
      final response = await _api.getApi(url);
      return SeriesResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<EpisodeResModel> fetchEpisodes(String seriesId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _api.setToken(token);
      }
      final response = await _api.getApi(AppUrls.episodesList(seriesId));
      return EpisodeResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<FavoriteResModel> fetchFavorites() async {
    try {
      final token = HiveService.getToken();
      _api.setToken(token!);
      final response = await _api.getApi(AppUrls.favoriteList);
      return FavoriteResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addFavorite(String seriesId) async {
    try {
      final token = HiveService.getToken();
      _api.setToken(token!);
      final response = await _api.postApi("${AppUrls.favoriteList}/$seriesId", {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteFavorite(String seriesId) async {
    try {
      final token = HiveService.getToken();
      _api.setToken(token!);
      final response = await _api.deleteApi(AppUrls.deleteFavorite(seriesId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<PlayEpisodeResModel> playEpisode(String episodeId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.getApi(AppUrls.playEpisode(episodeId));
      return PlayEpisodeResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> unlockEpisode(String episodeId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.postApi(AppUrls.unlockEpisode(episodeId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> likeEpisode(String episodeId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.postApi(AppUrls.likeEpisode(episodeId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> dislikeEpisode(String episodeId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.deleteApi(AppUrls.likeEpisode(episodeId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getLikeStatus(String episodeId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.getApi(AppUrls.likeStatus(episodeId));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

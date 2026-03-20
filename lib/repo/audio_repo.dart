import '../data/network/api_network_service.dart';
import '../model/responce/audio_res_model/playlist_res_model.dart';
import '../model/responce/audio_res_model/song_play_res_model.dart';
import '../model/responce/audio_res_model/song_res_model.dart';
import '../model/responce/song_res_model/song_res_model.dart';
import '../res/app_url.dart';
import '../utils/hive_service/hive_service.dart';

class AudioRepo {
  final _api = NetworkApiService();

  Future<SongResModel> getSongs() async {
    try {
      final response = await _api.getApi(AppUrls.audioSongs);
      return SongResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaylistResModel> getPlaylist() async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.getApi(AppUrls.audioPlaylist);
      return PlaylistResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addToPlaylist(String songId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.postApi(AppUrls.togglePlaylist(songId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> removeFromPlaylist(String songId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.deleteApi(AppUrls.togglePlaylist(songId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<SongPlayResModel> getSongPlayData(String songId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);
      final response = await _api.getApi(AppUrls.playSong(songId));
      return SongPlayResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<FavoriteSongResModel> fetchFavoritesSong() async {
    try {
      final token = HiveService.getToken();
      _api.setToken(token!);
      final response = await _api.getApi(AppUrls.favoriteSong);
      return FavoriteSongResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addFavoriteSong(String songid) async {
    try {
      final token = HiveService.getToken();
      _api.setToken(token!);
      final response = await _api.postApi(AppUrls.addFavoriteSong(songid), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteFavoriteSong(String songid) async {
    try {
      final token = HiveService.getToken();
      _api.setToken(token!);
      final response = await _api.deleteApi(AppUrls.deleteFavoriteSong(songid), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

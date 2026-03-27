import '../data/network/api_network_service.dart';
import '../model/responce/download_res_model/download_res_model.dart';
import '../res/app_url.dart';
import '../utils/hive_service/hive_service.dart';

class DownloadRepo {
  final _api = NetworkApiService();

  Future<dynamic> addOfflineDownload({
    String? seriesId,
    String? episodeId,
    String? songId,
    required String contentType,
  }) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      final Map<String, dynamic> body = {
        "contentType": contentType,
      };

      if (seriesId != null) body["seriesId"] = seriesId;
      if (episodeId != null) body["episodeId"] = episodeId;
      if (songId != null) body["songId"] = songId;

      final response = await _api.postApi(AppUrls.addDownload, body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<DownloadResModel> getOfflineDownloads() async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      final response = await _api.getApi(AppUrls.getdownload);
      return DownloadResModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteDownload(String downloadId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      final response = await _api.deleteApi(AppUrls.deleteDownload(downloadId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

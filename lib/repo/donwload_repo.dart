import '../data/network/api_network_service.dart';
import '../model/responce/download_res_model/download_res_model.dart';
import '../res/app_url.dart';
import '../utils/hive_service/hive_service.dart';

class DownloadRepo {
  final _api = NetworkApiService();

  Future<dynamic> addOfflineDownload({
    required String seriesId,
    required String episodeId,
  }) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      // Change the order of arguments inside postApi
      final response = await _api.postApi(
        AppUrls.addDownload, // 1st argument: String (URL)
        {                    // 2nd argument: Map (Body)
          "contentType": "EPISODE",
          "seriesId": seriesId,
          "episodeId": episodeId,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// get donwloads

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
/// delete download
  Future<dynamic> deleteDownload(String downloadId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      // Using the DELETE method for the specific download ID
      final response = await _api.deleteApi(AppUrls.deleteDownload(downloadId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
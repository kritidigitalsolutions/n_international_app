import '../data/network/api_network_service.dart';
import '../res/app_url.dart';
import '../utils/hive_service/hive_service.dart';

class HistoryRepo {
  final _api = NetworkApiService();
  /// add history
  Future<dynamic> addWatchHistory(Map<String, dynamic> data) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      final response = await _api.postApi(AppUrls.addHistory, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
/// get history
  Future<dynamic> getWatchHistory() async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      final response = await _api.getApi(AppUrls.getHistory);

      print("📥 HISTORY RESPONSE: $response");

      return response;
    } catch (e) {
      print("❌ GET HISTORY ERROR: $e");
      rethrow;
    }
  }
  /// delete history
  Future<dynamic> deleteHistory(String historyId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) _api.setToken(token);

      final response =
      await _api.deleteApi(AppUrls.deleteHistory(historyId), {});

      print("🗑 DELETE RESPONSE: $response");

      return response;
    } catch (e) {
      print("❌ DELETE ERROR: $e");
      rethrow;
    }
  }
}
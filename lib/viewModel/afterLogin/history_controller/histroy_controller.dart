import 'package:get/get.dart';
import '../../../repo/history_repo.dart';

class HistoryController extends GetxController {
  final HistoryRepo _repo = HistoryRepo();
  var historyList = [].obs;
  var isLoading = false.obs;

  Future<void> updateWatchHistory({
    required String seriesId,
    required String episodeId,
    required int progressSeconds,
  }) async {
    try {
      final body = {
        "contentType": "EPISODE",
        "seriesId": seriesId,
        "episodeId": episodeId,
        "progressSeconds": progressSeconds
      };

      print("📤 API BODY: $body");

      final response = await _repo.addWatchHistory(body);

      print("✅ API RESPONSE: $response");
    } catch (e) {
      print("❌ API ERROR: $e");
    }
  }

  /// ✅ FETCH HISTORY
  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;

      final response = await _repo.getWatchHistory();

      if (response['success'] == true) {
        historyList.value = response['history'];

        print("✅ HISTORY LIST: ${historyList.length}");
      }
    } catch (e) {
      print("❌ FETCH ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }
/// delete history
  Future<void> removeHistory(String historyId, int index) async {
    try {
      print("🗑 Deleting ID: $historyId");

      await _repo.deleteHistory(historyId);

      /// ✅ Remove from UI instantly
      historyList.removeAt(index);

      print("✅ Deleted Successfully");
    } catch (e) {
      print("❌ Delete Failed: $e");
    }
  }
}

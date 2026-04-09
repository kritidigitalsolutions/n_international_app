import 'package:dio/dio.dart';
import 'package:n_square_international/model/responce/notification_response.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/utils/hive_service/hive_service.dart';

class NotificationRepo {
  final Dio _dio = Dio();

  Future<void> updateFcmToken(String fcmToken) async {
    final token = HiveService.getToken();
    if (token == null) return;

    try {
      await _dio.post(
        AppUrls.updateFcmToken,
        data: {"fcmToken": fcmToken},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      print("✅ FCM Token updated on backend");
    } catch (e) {
      print("❌ Update FCM Token API Error: $e");
    }
  }

  Future<NotificationResponse> getNotifications() async {
    final token = HiveService.getToken();
    try {
      final response = await _dio.get(
        AppUrls.notification,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      return NotificationResponse.fromJson(response.data);
    } catch (e) {
      print("Notification API Error: $e");
      rethrow;
    }
  }

  Future<void> readNotification(String notificationId) async {
    final token = HiveService.getToken();
    try {
      await _dio.patch(
        AppUrls.readNotification(notificationId),
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } catch (e) {
      print("Read Notification API Error: $e");
    }
  }

  Future<void> readAllNotifications() async {
    final token = HiveService.getToken();
    try {
      await _dio.post(
        AppUrls.readallnotification,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } catch (e) {
      print("ReadAll Notification API Error: $e");
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final token = HiveService.getToken();
    try {
      await _dio.delete(
        "${AppUrls.notification}/$notificationId",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } catch (e) {
      print("Delete Notification API Error: $e");
    }
  }
}

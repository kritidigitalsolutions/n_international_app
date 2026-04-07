import 'package:dio/dio.dart';
import 'package:n_square_international/model/responce/notification_response.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/utils/hive_service/hive_service.dart';

class NotificationRepo {
  final Dio _dio = Dio();

  Future<NotificationResponse> getNotifications() async {
    final user = await HiveService.getUser();
    final token = user?.token ?? "";

    try {
      final response = await _dio.get(
        AppUrls.notification,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        return NotificationResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to load notifications");
      }
    } catch (e) {
      print("Notification API Error: $e");
      rethrow;
    }
  }

  Future<void> readNotification(String notificationId) async {
    final user = await HiveService.getUser();
    final token = user?.token ?? "";

    try {
      await _dio.get(
        AppUrls.readNotification(notificationId),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      print("Read Notification API Error: $e");
    }
  }

  Future<void> readAllNotifications() async {
    final user = await HiveService.getUser();
    final token = user?.token ?? "";

    try {
      await _dio.get(
        AppUrls.readallnotification,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      print("ReadAll Notification API Error: $e");
    }
  }
}

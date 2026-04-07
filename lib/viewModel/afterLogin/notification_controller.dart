import 'package:get/get.dart';
import 'package:n_square_international/model/responce/notification_response.dart';
import 'package:n_square_international/repo/notification_repo.dart';

class NotificationController extends GetxController {
  final NotificationRepo _repo = NotificationRepo();
  
  var isLoading = false.obs;
  var notifications = <NotificationItem>[].obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await _repo.getNotifications();
      if (response.success == true) {
        notifications.assignAll(response.items ?? []);
        unreadCount.value = response.unreadCount ?? 0;
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repo.readNotification(notificationId);
      
      // Update local state
      int index = notifications.indexWhere((item) => item.sId == notificationId);
      if (index != -1 && notifications[index].isRead == false) {
        notifications[index].isRead = true;
        notifications.refresh();
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repo.readAllNotifications();
      unreadCount.value = 0;
      for (var item in notifications) {
        item.isRead = true;
      }
      notifications.refresh();
    } catch (e) {
      print("Error marking all as read: $e");
    }
  }
}

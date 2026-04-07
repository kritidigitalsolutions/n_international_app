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
    final index = notifications.indexWhere((item) => item.sId == notificationId);
    if (index != -1) {
      final item = notifications[index];
      
      // Only proceed if it's currently unread
      if (item.isRead == false || item.isRead == null) {
        // 1. Optimistic Update: Immediately update UI
        item.isRead = true;
        notifications[index] = item; // Re-assign to trigger update
        
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
        notifications.refresh();

        // 2. Background API Call (PATCH)
        try {
          await _repo.readNotification(notificationId);
        } catch (e) {
          print("Error marking notification as read: $e");
          // If the API fails, we could optionally refresh the list
          // fetchNotifications();
        }
      }
    }
  }

  Future<void> markAllAsRead() async {
    // 1. Optimistic Update for all
    for (var item in notifications) {
      item.isRead = true;
    }
    unreadCount.value = 0;
    notifications.refresh();

    // 2. Background API Call (POST)
    try {
      await _repo.readAllNotifications();
    } catch (e) {
      print("Error marking all as read: $e");
      fetchNotifications(); // Sync back from server on error
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    int index = notifications.indexWhere((item) => item.sId == notificationId);
    if (index != -1) {
      bool wasUnread = notifications[index].isRead == false || notifications[index].isRead == null;
      
      notifications.removeAt(index);
      if (wasUnread && unreadCount.value > 0) {
        unreadCount.value--;
      }
      notifications.refresh();

      try {
        await _repo.deleteNotification(notificationId);
      } catch (e) {
        print("Error deleting notification: $e");
      }
    }
  }
}

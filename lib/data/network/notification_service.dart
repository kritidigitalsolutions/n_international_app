import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../viewModel/afterLogin/notification_controller.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🔥 BACKGROUND HANDLER
  @pragma('vm:entry-point')
  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
    _showNotificationInternal(message);
  }

  // 🔥 INIT
  static Future<void> init() async {
    // 1. Request Permission (Must for Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('User granted permission: ${settings.authorizationStatus}');

    // 2. Init Local Notification with a safe icon
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification clicked: ${response.payload}");
      },
    );

    // 3. Create High Importance Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔥 FOREGROUND MESSAGE RECEIVED: ${message.data}");
      _showNotificationInternal(message);

      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().addFromFCM(message);
      }
    });

    // 5. App Opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🔥 App opened from notification click");
    });
    
    // Token for backend testing
    String? token = await _messaging.getToken();
    print("🔥 FCM TOKEN: $token");
  }

  // 🔥 SHOW NOTIFICATION (Internal function for both foreground/background)
  static Future<void> _showNotificationInternal(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    
    // Data payload se values nikalna agar notification object null hai
    String title = notification?.title ?? message.data['title'] ?? "N International";
    String body = notification?.body ?? message.data['message'] ?? message.data['body'] ?? "New update available";

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
      payload: message.data.toString(),
    );
  }
}

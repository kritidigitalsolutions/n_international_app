import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:n_square_international/repo/notification_repo.dart';
import '../../viewModel/afterLogin/notification_controller.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final NotificationRepo _repo = NotificationRepo();



  // 🔥 BACKGROUND HANDLE
  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    // 🔥 IMPORTANT: initialize local notification again
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    _showNotificationInternal(message);
  }

  // 🔥 INIT
  static Future<void> init() async {



    // ✅ Local Notification Init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        print("👉 LOCAL NOTIFICATION CLICKED");
        print("👉 Payload: ${response.payload}");
      },
    );

    print("✅ Local Notification Initialized");

    // ✅ Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print("✅ Notification Channel Created");

    // ✅ TOKEN DEBUG
    String? token = await _messaging.getToken();
    print("🔥 TOKEN (INIT): $token");

    // ✅ TOKEN REFRESH
    _messaging.onTokenRefresh.listen((newToken) {
      print("🔄 TOKEN REFRESHED: $newToken");
    });

    // ✅ FOREGROUND LISTENER
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 FOREGROUND MESSAGE RECEIVED");
      print("📩 Title: ${message.notification?.title}");
      print("📩 Body: ${message.notification?.body}");
      print("📦 Data: ${message.data}");

      _showNotificationInternal(message);

      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().addFromFCM(message);
      }
    });

    // ✅ BACKGROUND CLICK (APP OPEN FROM NOTIFICATION)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 NOTIFICATION CLICKED (BACKGROUND)");
      print("📦 Data: ${message.data}");
    });

    // ✅ TERMINATED STATE CLICK
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print("🚀 APP OPENED FROM TERMINATED STATE");
      print("📦 Data: ${initialMessage.data}");
    }

    print("✅ NotificationService INIT DONE");
  }



  // 🔥 PUBLIC METHOD TO SYNC TOKEN (Call this after login)
  static Future<void> syncTokenToServer() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print("🔥 Syncing FCM Token: $token");
        await _repo.updateFcmToken(token);
      }
    } catch (e) {
      print("Error syncing token: $e");
    }
  }

  // 🔥 SHOW NOTIFICATION INTERNAL
  static Future<void> _showNotificationInternal(RemoteMessage message) async {
    print("🔔 SHOWING LOCAL NOTIFICATION"); // 👈 ADD THIS

    RemoteNotification? notification = message.notification;

    String title = notification?.title ?? message.data['title'] ?? "N International";
    String body = notification?.body ?? message.data['message'] ?? message.data['body'] ?? "";

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}

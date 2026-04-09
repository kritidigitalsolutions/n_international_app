import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_pages.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/bottom_navigationbar.dart';
import 'package:n_square_international/utils/hive_service/userdetail.dart';
import 'package:n_square_international/utils/hive_service/userdetail.g.dart';
import 'package:n_square_international/viewModel/afterLogin/bottom_nac_controller.dart';
import 'data/network/notification_service.dart';

// 🔥 BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  print("🌙 BACKGROUND HANDLER TRIGGERED");
  print("📩 BG Title: ${message.notification?.title}");
  print("📩 BG Body: ${message.notification?.body}");
  print("📦 BG Data: ${message.data}");

  await NotificationService.backgroundHandler(message);
}

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🚀 APP STARTED");

  // 🔥 Firebase Init
  await Firebase.initializeApp();
  print("🔥 Firebase Initialized");

  // 🔔 Background Notification Setup
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  print("🌙 Background handler registered");

  // 📱 Token Debug
  String? token = await FirebaseMessaging.instance.getToken();
  print("🔥 FCM TOKEN (MAIN): $token");

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("🔄 FCM TOKEN REFRESHED (MAIN): $newToken");
  });

  // 📦 Hive Init
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(UserDetailsAdapter().typeId)) {
    Hive.registerAdapter(UserDetailsAdapter());
  }
  await Hive.openBox<UserDetails>('userBox');
  print("📦 Hive Initialized");

  // 🚫 Screenshot Block
  final NoScreenshot noScreenshot = NoScreenshot.instance;
  await noScreenshot.screenshotOff();
  print("🚫 Screenshot Disabled");

  // ❌ REMOVE THIS (IMPORTANT)
  // await NotificationService.init();

  runApp(const MyApp());
}

////////////////////////////////////////////////////////////
/// ✅ FIXED HERE
////////////////////////////////////////////////////////////

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // 🔥 SAFE CALL AFTER UI READY
    Future.delayed(const Duration(seconds: 1), () async {
      print("🚀 Calling NotificationService.init AFTER UI");

      await NotificationService.init();

      print("🔔 NotificationService Initialized (SAFE)");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("🎨 Building MyApp");

    return GetMaterialApp(
      title: "OTT App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: "Poppins",
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      navigatorObservers: [routeObserver],
    );
  }
}

////////////////////////////////////////////////////////////

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final BottomNavController controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    print("🏠 MyHomePage Loaded");

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            backgroundGradient(),
            Obx(() {
              print("🔄 Page Changed Index: ${controller.currentIndex.value}");
              return controller.pages[controller.currentIndex.value];
            }),
          ],
        ),
        bottomNavigationBar: Obx(
              () => CustomBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: (index) {
              print("👉 Bottom Nav Clicked: $index");
              controller.changeIndex(index);
            },
          ),
        ),
      ),
    );
  }
}

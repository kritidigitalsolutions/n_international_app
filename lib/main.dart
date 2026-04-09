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

// 🔥 REQUIRED
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await NotificationService.backgroundHandler(message);
}

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // ✅ BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // ✅ INIT NOTIFICATION
  await NotificationService.init();

  // Hive init
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(UserDetailsAdapter().typeId)) {
    Hive.registerAdapter(UserDetailsAdapter());
  }
  await Hive.openBox<UserDetails>('userBox');

  // Screenshot block
  final NoScreenshot noScreenshot = NoScreenshot.instance;
  await noScreenshot.screenshotOff();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  final BottomNavController controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            backgroundGradient(),
            Obx(() => controller.pages[controller.currentIndex.value]),
          ],
        ),
        bottomNavigationBar: Obx(
              () => CustomBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeIndex,
          ),
        ),
      ),
    );
  }
}

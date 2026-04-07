import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_pages.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/bottom_navigationbar.dart';
import 'package:n_square_international/utils/hive_service/userdetail.dart';
import 'package:n_square_international/utils/hive_service/userdetail.g.dart';
import 'package:n_square_international/viewModel/afterLogin/bottom_nac_controller.dart';
import 'package:no_screenshot/no_screenshot.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapter for UserDetails
  if (!Hive.isAdapterRegistered(UserDetailsAdapter().typeId)) {
    Hive.registerAdapter(UserDetailsAdapter());
  }

  // Open the box
  await Hive.openBox<UserDetails>('userBox');

  // Enable Screenshot and Screen Recording protection
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      initialRoute: AppRoutes.splash,

      getPages: AppPages.routes,

      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
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

            /// PAGE SWITCH
            Obx(() => controller.pages[controller.currentIndex.value]),
          ],
        ),

        /// BOTTOM NAV
        bottomNavigationBar: Obx(
          () => CustomBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: (index) {
              controller.changeIndex(index);
            },
          ),
        ),
      ),
    );
  }
}

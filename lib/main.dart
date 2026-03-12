import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_pages.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/bottom_navigationbar.dart';
import 'package:n_square_international/viewModel/afterLogin/bottom_nac_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return Scaffold(
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
    );
  }
}

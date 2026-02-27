import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_pages.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/bottom_navigationbar.dart';
import 'package:n_square_international/views/afterLogin/home_screen/favorite_screen.dart';
import 'package:n_square_international/views/afterLogin/home_screen/home_screen.dart';
import 'package:n_square_international/views/afterLogin/profile/profile_page.dart';
import 'package:n_square_international/views/afterLogin/reel_page/reel_page.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    ReelPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          backgroundGradient(),
          pages[currentIndex],

          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: CustomBottomNavBar(
          //     currentIndex: currentIndex,
          //     onTap: (index) {
          //       setState(() {
          //         currentIndex = index;
          //       });
          //     },
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

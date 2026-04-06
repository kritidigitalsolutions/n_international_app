import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/views/afterLogin/home_screen/favorite_screen.dart';
import 'package:n_square_international/views/afterLogin/home_screen/home_screen.dart';
import 'package:n_square_international/views/afterLogin/profile/profile_page.dart';
import 'package:n_square_international/views/afterLogin/reel_page/reel_page.dart';
import 'package:n_square_international/viewModel/afterLogin/reel_controller/reel_controller.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;

    // Pause reels if user switches away from the ReelPage (index 2)
    if (Get.isRegistered<ReelController>()) {
      final reelController = Get.find<ReelController>();
      if (index != 2) {
        reelController.pauseAll();
      } else {
        reelController.resumeCurrent();
      }
    }
  }

  final List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    ReelPage(),
    ProfilePage(),
  ];
}

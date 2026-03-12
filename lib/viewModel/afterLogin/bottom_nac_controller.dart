import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/views/afterLogin/home_screen/favorite_screen.dart';
import 'package:n_square_international/views/afterLogin/home_screen/home_screen.dart';
import 'package:n_square_international/views/afterLogin/profile/profile_page.dart';
import 'package:n_square_international/views/afterLogin/reel_page/reel_page.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  final List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    ReelPage(),
    ProfilePage(),
  ];
}

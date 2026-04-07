import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/responce/series_res_model/series_res_model.dart';
import '../../repo/series_repo.dart';

class HomeController extends GetxController {
  final SeriesRepo _repo = SeriesRepo();

  /// API State
  var seriesResponse = ApiResponse<SeriesResModel>.loading().obs;

  /// Category Lists
  var popularSeries = <Series>[].obs;
  var latestSeries = <Series>[].obs;
  var romanticSeries = <Series>[].obs;
  var revengeSeries = <Series>[].obs;
  var newReleaseSeries = <Series>[].obs;

  /// Search State
  var searchResults = <Series>[].obs;
  var isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  /// Tabs
  var selectedTabIndex = 0.obs;

  final List<String> tabs = [
    "Popular",
    "Latest",
    "Romantic",
    "Revenge Drama",
  ];

  /// 🔥 Dynamic List based on selected tab
  List<Series> get currentSeriesList {
    if (isSearching.value) {
      return searchResults;
    }
    switch (selectedTabIndex.value) {
      case 0:
        return popularSeries;
      case 1:
        return latestSeries;
      case 2:
        return romanticSeries;
      case 3:
        return revengeSeries;
      default:
        return popularSeries;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchSeries();
  }

  /// API Call
  Future<void> fetchSeries() async {
    seriesResponse.value = ApiResponse.loading();

    try {
      final response = await _repo.fetchSeries();
      seriesResponse.value = ApiResponse.completed(response);

      if (response.series != null) {
        final list = response.series!;

        popularSeries.assignAll(
          list.where((s) => s.isPopular ?? false).toList(),
        );

        latestSeries.assignAll(
          list.where((s) => s.isLatest ?? false).toList(),
        );

        romanticSeries.assignAll(
          list.where((s) => s.isRomantic ?? false).toList(),
        );

        revengeSeries.assignAll(
          list.where((s) => s.isRevengeDrama ?? false).toList(),
        );

        newReleaseSeries.assignAll(
          list.where((s) => s.isNewRelease ?? false).toList(),
        );
      }
    } catch (e) {
      seriesResponse.value = ApiResponse.error(e.toString());
    }
  }

  /// Search API Call
  Future<void> searchSeries(String query) async {
    if (query.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      final response = await _repo.fetchSeries(search: query);
      if (response.series != null) {
        searchResults.assignAll(response.series!);
      }
    } catch (e) {
      print("Search error: $e");
    }
  }

  void clearSearch() {
    searchController.clear();
    isSearching.value = false;
    searchResults.clear();
  }

  /// Tab Change
  void changeTab(int index) {
    selectedTabIndex.value = index;
    // Clear search when switching tabs if you want
    // isSearching.value = false;
  }

  /// Snackbar
  Future<void> checkFirstTimeSnackbar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstVisit = prefs.getBool('is_first_home_visit') ?? true;

    if (!isFirstVisit) return;

    Future.delayed(const Duration(milliseconds: 400), () {
      Get.showSnackbar(
        GetSnackBar(
          snackPosition: SnackPosition.TOP,
          backgroundGradient: LinearGradient(
            colors: [
              AppColors.accentRed.withAlpha(150),
              AppColors.buttonColor.withAlpha(80),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          margin: const EdgeInsets.fromLTRB(12, 40, 12, 0),
          borderRadius: 16,
          duration: const Duration(seconds: 8),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeIn,
          barBlur: 4,
          snackStyle: SnackStyle.FLOATING,
          icon: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            size: 36,
          ),
          titleText: Text(
            "Rs 50 Wallet",
            style: text18(
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          messageText: Text(
            "Added to you Wallet",
            style: text14(color: AppColors.textSecondary),
          ),
          mainButton: GestureDetector(
            onTap: () => Get.back(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "×",
                style: text24(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
    });

    await prefs.setBool('is_first_home_visit', false);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

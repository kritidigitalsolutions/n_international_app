import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../../model/responce/series_res_model/series_res_model.dart';
import '../../repo/series_repo.dart';

class HomeController extends GetxController {
  final SeriesRepo _repo = SeriesRepo();

  var seriesResponse = ApiResponse<SeriesResModel>.loading().obs;
  var popularSeries = <Series>[].obs;
  var latestSeries = <Series>[].obs;
  var romanticSeries = <Series>[].obs;
  var revengeSeries = <Series>[].obs;
  var newReleaseSeries = <Series>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSeries();
  }

  Future<void> fetchSeries() async {
    seriesResponse.value = ApiResponse.loading();
    try {
      final response = await _repo.fetchSeries();
      seriesResponse.value = ApiResponse.completed(response);

      if (response.series != null) {
        popularSeries.assignAll(response.series!.where((s) => s.isPopular ?? false).toList());
        latestSeries.assignAll(response.series!.where((s) => s.isLatest ?? false).toList());
        romanticSeries.assignAll(response.series!.where((s) => s.isRomantic ?? false).toList());
        revengeSeries.assignAll(response.series!.where((s) => s.isRevengeDrama ?? false).toList());
        newReleaseSeries.assignAll(response.series!.where((s) => s.isNewRelease ?? false).toList());
      }
    } catch (e) {
      seriesResponse.value = ApiResponse.error(e.toString());
    }
  }

  Future<void> checkFirstTimeSnackbar() async {
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
  }

  final List<Map<String, String>> seriesList = [
    {"image": "assets/images/image2.png", "title": "Our Secret"},
    {"image": "assets/images/image1.png", "title": "Shadow & Bone"},
    {"image": "assets/images/image3.png", "title": "Peaky Blinders"},
    {"image": "assets/images/image2.png", "title": "Our Secret"},
    {"image": "assets/images/image1.png", "title": "Shadow & Bone"},
    {"image": "assets/images/image3.png", "title": "Peaky Blinders"},
  ];

  var selectedTabIndex = 0.obs;

  final List<String> tabs = ["Popular", "Latest", "Romantic", "Revenge Drama"];

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }
}

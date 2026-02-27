import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';

class CustomSnackbar {
  // Show success snackbar
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.textPrimary,
      icon: const Icon(Icons.check_circle, color: AppColors.textPrimary),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutBack,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // Show error snackbar
  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.textPrimary,
      icon: const Icon(Icons.error, color: AppColors.textPrimary),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutBack,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // Show info snackbar
  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: AppColors.textPrimary,
      icon: const Icon(Icons.info, color: AppColors.textPrimary),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutBack,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}

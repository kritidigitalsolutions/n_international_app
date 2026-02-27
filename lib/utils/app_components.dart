import 'package:flutter/material.dart';
import 'package:n_square_international/res/app_colors.dart';

Widget backgroundGradient() {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.transparent, AppColors.accentRed.withAlpha(100)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 1.0],
      ),
    ),
  );
}

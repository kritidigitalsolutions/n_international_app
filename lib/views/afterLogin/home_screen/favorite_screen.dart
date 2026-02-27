import 'package:flutter/material.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Favorite\nDrama",
                  style: text18(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return favoriteCard();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget favoriteCard() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/image2.png",

                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.textSecondary);
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('Our Secret', style: text12(color: AppColors.textPrimary)),
            Text('Episode 10', style: text11(color: AppColors.textPrimary)),
          ],
        ),
        Positioned(
          right: -1,
          top: -2,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.background,
            child: Icon(Icons.delete, size: 16, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

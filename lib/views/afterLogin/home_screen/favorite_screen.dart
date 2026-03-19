import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/model/responce/series_res_model/favorite_res_model.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/favorite_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoriteController());

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
                  style: text18(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Obx(() {
                    switch (controller.favoriteResponse.value.status) {
                      case Status.loading:
                        return const Center(child: CircularProgressIndicator());
                      case Status.error:
                        return Center(
                          child: Text(
                            controller.favoriteResponse.value.message ?? "Error",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      case Status.completed:
                        final items = controller.favoriteResponse.value.data?.items ?? [];
                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              "No favorites yet",
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Changed to 2 for better width
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 0.7, // Adjusted ratio for better dimensions
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return _favoriteCard(items[index], controller);
                          },
                        );
                      default:
                        return const SizedBox();
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteCard(FavoriteItem item, FavoriteController controller) {
    final series = item.series;
    return GestureDetector(
      onTap: () {
        if (series != null) {
          Get.toNamed(AppRoutes.seriesDetails, arguments: series);
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.white.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: series?.posterImage != null && series!.posterImage!.isNotEmpty
                        ? Image.network(
                            AppUrls.getImageUrl(series.posterImage),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.textSecondary,
                                width: double.infinity,
                                child: const Icon(Icons.broken_image, color: Colors.white30),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.textSecondary,
                            width: double.infinity,
                            child: const Icon(Icons.image, color: Colors.white30),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        series?.title ?? 'No Title',
                        style: text14(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${series?.totalEpisodes ?? 0} Episodes',
                        style: text12(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 5,
            top: 5,
            child: GestureDetector(
              onTap: () {
                if (series?.sId != null) {
                  controller.removeFromFavorite(series!.sId!);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

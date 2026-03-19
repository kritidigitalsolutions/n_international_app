import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../../../data/api_responce_data.dart';
import '../../../model/responce/series_res_model/episode_res_model.dart';
import '../../../model/responce/series_res_model/series_res_model.dart';
import '../../../viewModel/afterLogin/SeriesDetail/series_detail_controller.dart';

class SeriesDetailPage extends StatefulWidget {
  const SeriesDetailPage({super.key});

  @override
  State<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends State<SeriesDetailPage> {
  final SeriesDetailController controller = Get.put(SeriesDetailController());
  late Series series;

  @override
  void initState() {
    super.initState();
    series = Get.arguments as Series;
    if (series.sId != null) {
      controller.fetchEpisodes(series.sId!);
      controller.checkIsFavorite(series.sId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.transparent, AppColors.accentRed.withAlpha(100)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Poster
                Container(
                  margin: const EdgeInsets.all(16),
                  height: size.height * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: series.posterImage != null && series.posterImage!.isNotEmpty
                          ? NetworkImage(series.posterImage!) as ImageProvider
                          : const AssetImage("assets/images/image2.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                /// Title + Favorite Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              series.title ?? "Untitled",
                              style: text18(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              series.languages?.join(" | ") ?? "No language info",
                              style: text12(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "4.8/5 (200k+ reviews)",
                                  style: text11(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Obx(() => IconButton(
                        icon: Icon(
                          controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                          color: controller.isFavorite.value ? AppColors.error : AppColors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          if (series.sId != null) {
                            controller.toggleFavorite(series.sId!);
                          }
                        },
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// About Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.3),
                    border: Border.all(
                      color: AppColors.white.withAlpha(50),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About This Series",
                        style: text16(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Watch full episodes of ${series.title} every day and witness an emotional love story between two souls.",
                        style: text13(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Episodes List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    switch (controller.episodesResponse.value.status) {
                      case Status.loading:
                        return const Center(child: CircularProgressIndicator());
                      case Status.error:
                        return Center(
                          child: Text(
                            controller.episodesResponse.value.message ?? "Error loading episodes",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      case Status.completed:
                        final episodes = controller.episodesResponse.value.data?.episodes ?? [];
                        if (episodes.isEmpty) {
                          return const Center(
                            child: Text(
                              "No episodes found",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return Column(
                          children: episodes.map((episode) => _episodeTile(episode)).toList(),
                        );
                      default:
                        return const SizedBox();
                    }
                  }),
                ),

                const SizedBox(height: 20),

                /// Similar Series
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Watch similar series like this!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.videoPlay);
                        },
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage("assets/images/image1.png"),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _episodeTile(Episode episode) {
    return GestureDetector(
      onTap: () {
        if (!(episode.isLocked ?? false)) {
          controller.playEpisode(episode.id!);
        } else {
          Get.snackbar("Locked", "Please unlock this episode to watch",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error.withOpacity(0.8),
              colorText: Colors.white
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withAlpha(50), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: episode.thumbnail != null && episode.thumbnail!.isNotEmpty
                      ? NetworkImage(episode.thumbnail!)
                      : const NetworkImage("https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Episode ${episode.episodeNumber}",
                        style: text15(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (episode.isLocked ?? false)
                        const Icon(Icons.lock, size: 15, color: AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode.title ?? "No title",
                    style: text12(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              episode.isLocked ?? false ? "Unlock" : "Play Now",
              style: text15(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

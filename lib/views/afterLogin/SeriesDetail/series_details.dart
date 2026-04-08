import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../../../data/api_responce_data.dart';
import '../../../model/responce/series_res_model/episode_res_model.dart';
import '../../../model/responce/series_res_model/series_res_model.dart';
import '../../../viewModel/afterLogin/SeriesDetail/series_detail_controller.dart';
import '../../../viewModel/afterLogin/download_controller/download_controller.dart';
import '../../../viewModel/afterLogin/home_controller.dart';
import '../../../viewModel/afterLogin/user_controller/full_profile_controller.dart';

class SeriesDetailPage extends StatefulWidget {
  const SeriesDetailPage({super.key});

  @override
  State<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends State<SeriesDetailPage> {
  final SeriesDetailController controller = Get.put(SeriesDetailController(), permanent: true);
  final DownloadController downloadController = Get.put(DownloadController());
  final HomeController homeController = Get.put(HomeController());
  final FullProfileController profileController = Get.put(FullProfileController());
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
      body: Stack(
        children: [
          Container(
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
                          image:
                          NetworkImage(series.bannerImage ?? ''),
                          //: const AssetImage("assets/images/image2.png"),
                          onError: (exception, stackTrace) => Center(
                              child: Icon(Icons.image, size: 50)
                          ),
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
                                    const SizedBox(width: 15),
                                    const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Obx(() => Text(
                                      "₹${profileController.walletBalance.value}",
                                      style: text11(color: Colors.amber),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Obx(() => controller.isFavoriteLoading.value
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary, // Yellow/Gold
                                    ),
                                  ),
                                )
                              : IconButton(
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
                        /// 🔥 FIX: Wait until local + API data ready
                        if (controller.isInitialLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        switch (controller.episodesResponse.value.status) {
                          case Status.loading:
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            );

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
                      })
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
                      height: 180,
                      child: Obx(() {
                        List<Series> similarSeries = [];

                        /// 🔥 Check all flags dynamically
                        if (series.isPopular == true) {
                          similarSeries.addAll(homeController.popularSeries);
                        }
                        if (series.isLatest == true) {
                          similarSeries.addAll(homeController.latestSeries);
                        }
                        if (series.isRomantic == true) {
                          similarSeries.addAll(homeController.romanticSeries);
                        }
                        if (series.isRevengeDrama == true) {
                          similarSeries.addAll(homeController.revengeSeries);
                        }

                        /// ✅ Remove current series + duplicates
                        var filtered = similarSeries
                            .where((s) => s.sId != series.sId)
                            .fold<Map<String, Series>>(
                          {},
                              (map, s) => map..putIfAbsent(s.sId ?? "", () => s),
                        )
                            .values
                            .toList();

                        /// 🔥 Fallback if nothing matched
                        if (filtered.isEmpty) {
                          filtered = homeController.popularSeries
                              .where((s) => s.sId != series.sId)
                              .toList();
                        }

                        /// ❌ Still empty
                        if (filtered.isEmpty) {
                          return const Center(
                            child: Text(
                              "No similar series found",
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        /// ✅ UI
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];

                            return GestureDetector(
                              onTap: () {
                                Get.offNamed(
                                  AppRoutes.seriesDetails,
                                  arguments: item,
                                  preventDuplicates: false,
                                );
                              },
                              child: Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          AppUrls.getImageUrl(item.posterImage),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.title ?? "",
                                      style: text12(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => controller.isUnlocking.value
              ? Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: AppColors.accentRed)))
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _episodeTile(Episode episode) {
    // An episode is UNLOCKED if any of these are true:
    bool isUnlocked = episode.alreadyUnlocked == true;
    bool isLocked = !isUnlocked;
    // bool isLocked = !isUnlocked;

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          final episodes = controller.episodesResponse.value.data?.episodes ?? [];
          Get.toNamed(
            AppRoutes.videoPlay,
            arguments: {
              'episodes': episodes,
              'initialIndex': episodes.indexOf(episode),
              'series': series,
            },
          );
        } else {
          _showUnlockDialog(episode);
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
              child: isLocked ? Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 24),
              ) : null,
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

            if (!isLocked)
              IconButton(
                icon: Obx(() {
                  bool isThisDownloading = downloadController.downloadingIds.contains(episode.id);
                  bool isDownloaded = downloadController.isDownloaded(episode.id!);

                  if (isThisDownloading) {
                    double progress = downloadController.downloadProgress[episode.id] ?? 0.0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2,
                          color: AppColors.primary, // Yellow/Gold
                          backgroundColor: Colors.white24,
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ],
                    );
                  } else if (isDownloaded) {
                    return const Icon(Icons.check_circle, color: Colors.green);
                  } else {
                    return const Icon(Icons.download_for_offline, color: Colors.white);
                  }
                }),
                onPressed: () {
                  if (episode.id != null) {
                    downloadController.startDownload(
                      seriesId: series.sId!,
                      episodeId: episode.id!,
                      downloadUrl: episode.videoUrl!,
                      contentType: "EPISODE",
                      title: series.title!,
                      image: episode.thumbnail,
                      subtitle: "Episode ${episode.episodeNumber}: ${episode.title ?? ''}",
                    );
                  } else {
                    Get.snackbar("Error", "ID missing for download");
                  }
                },
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLocked)
                  const Icon(Icons.lock_outline, color: Colors.amber, size: 18),
                Text(
                  isLocked ? "Unlock" : "Play Now",
                  style: text15(
                    color: isLocked ? Colors.amber : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUnlockDialog(Episode episode) {
    Get.defaultDialog(
      title: "Unlock Episode",
      middleText: "This episode is locked. Do you want to unlock it for ₹1?",
      backgroundColor: AppColors.background,
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "Unlock",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: AppColors.error,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        if (series.sId != null && episode.id != null) {
          controller.unlockEpisode(series.sId!, episode.id!);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/model/responce/series_res_model/favorite_res_model.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/favorite_controller.dart';

import '../../../viewModel/afterLogin/song_controller/song_controllers.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final controller = Get.put(FavoriteController());
  final songcontroller = Get.put(SongListController());


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    songcontroller.fetchFavoriteSong();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Title
            Text(
              "My Favorite",
              style: text18(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            /// Tabs
            TabBar(
              controller: _tabController,

              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,

              labelColor: AppColors.error,
              unselectedLabelColor: Colors.white,

              labelStyle: text14(fontWeight: FontWeight.bold),
              unselectedLabelStyle: text14(fontWeight: FontWeight.normal),

              tabs: const [
                Tab(text: "Series"),
                Tab(text: "Songs"),
              ],
            ),

            const SizedBox(height: 10),

            /// Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _seriesTab(),
                  _songsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// SERIES TAB (Existing)
  /// =======================
  Widget _seriesTab() {
    return Obx(() {
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
          final items =
              controller.favoriteResponse.value.data?.items ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "No favorites yet",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return GridView.builder(
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _favoriteCard(items[index]);
            },
          );

        default:
          return const SizedBox();
      }
    });
  }

  /// =======================
  /// SONGS TAB
  /// =======================
  Widget _songsTab() {
    return Obx(() {
      switch (songcontroller.favoriteSongResponse.value.status) {

        case Status.loading:
          return const Center(child: CircularProgressIndicator());

        case Status.error:
          return Center(
            child: Text(
              songcontroller.favoriteSongResponse.value.message ?? "Error",
              style: const TextStyle(color: Colors.white),
            ),
          );

        case Status.completed:
          final songs = songcontroller.favoriteSongs;

          if (songs.isEmpty) {
            return const Center(
              child: Text(
                "No favorite songs",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),

                title: Text(
                  song.title ?? "",
                  style: text14(color: AppColors.textPrimary),
                ),

                subtitle: Text(
                  song.artist ?? "",
                  style: text12(color: AppColors.textSecondary),
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    if (song.id != null) {
                      songcontroller.toggleFavorite(song.id!);
                    }
                  },
                ),

                onTap: () {
                  // 👉 Navigate to player if needed
                },
              );
            },
          );
        default:
          return const SizedBox();
      }
    });
  }

  /// =======================
  /// SERIES CARD
  /// =======================
  Widget _favoriteCard(FavoriteItem item) {
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

          /// Remove Button
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

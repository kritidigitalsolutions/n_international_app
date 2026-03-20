// listen_songs_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/song_controller/song_controllers.dart';

class ListenSongsPage extends StatelessWidget {
  const ListenSongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SongListController());

    return Scaffold(
      body: Stack(
        children: [
          backgroundGradient(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Drama Series",
                          style: text14(color: AppColors.textPrimary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.back();
                            },
                        ),
                        TextSpan(
                          text: " | ",
                          style: text14(color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: "Listen Songs",
                          style: text14(color: AppColors.error),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print("Listen Songs tapped");
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            CustomTextButton(
                              textColor: controller.index.value == 0
                                  ? AppColors.error
                                  : AppColors.white,
                              title: "Songs",
                              onPressed: () {
                                controller.toggle(0);
                              },
                            ),
                            const Text("|", style: TextStyle(color: AppColors.white)),
                            CustomTextButton(
                              textColor: controller.index.value == 1
                                  ? AppColors.error
                                  : AppColors.white,
                              title: "My Playlist",
                              onPressed: () {
                                controller.toggle(1);
                              },
                            ),
                          ],
                        ),
                        // Improved Dropdown UI
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.05),
                            border: Border.all(color: AppColors.white.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedLanguage.value,
                              dropdownColor: const Color(0xFF1A1A1A),
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                              style: text14(color: AppColors.white),
                              items: controller.languages.map((String lang) {
                                return DropdownMenuItem<String>(
                                  value: lang,
                                  child: Text(lang),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.changeLanguage(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// Tabs (Now always shown)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton('Popular', 0, controller),
                      _buildTabButton('Trending', 1, controller),
                      _buildTabButton('Top Charts', 2, controller),
                      _buildTabButton('New Releases', 3, controller),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// Song list
                Expanded(
                  child: Obx(() {
                    final isPlaylist = controller.index.value == 1;
                    final response = isPlaylist ? controller.playlistResponse.value : controller.songResponse.value;
                    final songs = isPlaylist ? controller.displayPlaylist : controller.displaySongs;

                    switch (response.status) {
                      case Status.loading:
                        return const Center(child: CircularProgressIndicator());
                      case Status.error:
                        return Center(
                          child: Text(
                            response.message ?? "Error",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      case Status.completed:
                        if (songs.isEmpty) {
                          return Center(
                            child: Text(
                              isPlaylist ? "No songs found in this category in your playlist" : "No songs found in this category",
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return ListTile(
                              onTap: () {
                                Get.toNamed(AppRoutes.musicPlay, arguments: song);
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  AppUrls.getImageUrl(song.thumbnailUrl),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.white.withOpacity(0.1),
                                      child: const Icon(Icons.music_note, color: Colors.white54),
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                song.title ?? "Unknown Title",
                                style: const TextStyle(color: AppColors.textPrimary),
                              ),
                              subtitle: Text(
                                song.artist ?? "Unknown Artist",
                                style: text12(color: AppColors.textSecondary),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                                onPressed: () => controller.showMoreOptions(index, isPlaylist: isPlaylist),
                              ),
                            );
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

  Widget _buildTabButton(
    String label,
    int index,
    SongListController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.error : AppColors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: text14(
              color: isSelected ? AppColors.error : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }
}

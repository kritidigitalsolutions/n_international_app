import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:share_plus/share_plus.dart';

import '../../../viewModel/afterLogin/song_controller/music_player_controller.dart';
import '../../../viewModel/afterLogin/song_controller/song_controllers.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicPlayerController controller =
    Get.put(MusicPlayerController());
    final SongListController favController =
    Get.put(SongListController());

    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.white, size: 30),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "NOW PLAYING",
          style: text14(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ).copyWith(letterSpacing: 2),
        ),

        /// 👉 SHARE BUTTON (RIGHT SIDE)
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
            children: [
              Obx(() {
                final songId = controller.currentSong.value?.id ?? "";
                final isFav =
                songId.isNotEmpty ? (favController.favoriteMap[songId] ?? false) : false;

                final playData = controller.songPlayResponse.value.data?.playData;

                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    if (playData?.id != null) {
                      favController.toggleFavorite(playData!.id!);
                    }
                  },
                );
              }),

              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  final playData =
                      controller.songPlayResponse.value.data?.playData;

                  Share.share(
                    "${playData?.title ?? ''} by ${playData?.artist ?? ''}",
                  );
                },
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          _backgroundGradient(),

          /// 🔥 MAIN CONTENT
          Obx(() {
            final response = controller.songPlayResponse.value;

            if (response.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final playData = response.data?.playData;
            if (playData == null) return const SizedBox();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
              children: [
              const SizedBox(height: 40),

              /// 🔥 IMAGE CENTER
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// 🎵 ALBUM ART
                    Obx(() {
                      final song = controller.currentSong.value;
                      final playData = controller.songPlayResponse.value.data?.playData;

                      final imageUrl =
                          playData?.thumbnailPlaybackUrl ??
                              playData?.thumbnailUrl ??
                              song?.thumbnailUrl;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: controller.isPlaying.value ? 280 : 260,
                        width: controller.isPlaying.value ? 280 : 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: (imageUrl != null && imageUrl.isNotEmpty)
                              ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                              : null,
                          color: Colors.grey.shade900,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? const Center(
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 80,
                          ),
                        )
                            : null,
                      );
                    }),
                  ],
                ),
              ),

              /// 🔽 CONTENT (THODA NICHE)
              Column(
                children: [
                  /// 🎵 TITLE
                  Text(
                    playData.title ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// 🎤 ARTIST
                  Text(
                    playData.artist ?? "",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 🎚 SEEK BAR
                  Obx(() {
                    return Column(
                      children: [
                        Slider(
                          value: controller.position.value.inSeconds.toDouble(),
                          max: controller.duration.value.inSeconds
                              .toDouble()
                              .clamp(1, double.infinity),
                          onChanged: (value) {
                            controller.seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: Colors.red,
                          inactiveColor: Colors.white24,
                        ),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.formatTime(controller.position.value),
                              style:
                              const TextStyle(color: Colors.white54),
                            ),
                            Text(
                              controller.formatTime(controller.duration.value),
                              style:
                              const TextStyle(color: Colors.white54),
                            ),
                          ],
                        )
                      ],
                    );
                  }),

                  const SizedBox(height: 20),

                  /// 🎮 CONTROLS
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shuffle, color: Colors.white54),

                        const SizedBox(width: 20),

                        const Icon(Icons.skip_previous,
                            color: Colors.white, size: 36),

                        const SizedBox(width: 20),

                        GestureDetector(
                          onTap: () {
                            if (controller.isPlaying.value) {
                              controller.pauseSong();
                            } else {
                              final url = playData.audioPlaybackUrl ??
                                  playData.audioUrl;
                              if (url != null) {
                                controller.playSong(url);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Icon(
                              controller.isPlaying.value
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        const Icon(Icons.skip_next,
                            color: Colors.white, size: 36),

                        const SizedBox(width: 20),

                        const Icon(Icons.repeat,
                            color: Colors.white54),
                      ],
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
              ],
            ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 🎨 Background
  Widget _backgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D0D0D),
            Color(0xFF1A0000),
            Color(0xFF000000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

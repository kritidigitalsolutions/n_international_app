import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vdocipher_flutter/vdocipher_flutter.dart';

import '../../../viewModel/afterLogin/song_controller/music_player_controller.dart';
import '../../../viewModel/afterLogin/song_controller/song_controllers.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicPlayerController controller =
    Get.put(MusicPlayerController());
    final SongListController favController = Get.put(SongListController());

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
      ),
      body: Stack(
        children: [
          _backgroundGradient(),

          /// 🔥 MAIN CONTENT
          Obx(() {
            final response = controller.songPlayResponse.value;

            /// Loading
            if (response.status == Status.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.error,
                ),
              );
            }

            /// Error
            if (response.status == Status.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    response.message ?? "Error loading song",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            final playData = response.data?.playData;

            if (playData == null) {
              return const Center(
                child: Text(
                  "No play data available",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final playback = playData.vdoCipherPlayback;

            return SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// 🎬 VdoCipher Player (MAIN)
                    if (playback != null)
                      Container(
                        height: mediaQuery.height * 0.30,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(20),
                          color: Colors.black,
                        ),
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(20),
                          child: VdoPlayer(
                            embedInfo: EmbedInfo.streaming(
                              otp: playback.otp ?? "",
                              playbackInfo: playback.playbackInfo ?? "",
                            ),
                            onPlayerCreated: (controller) {
                              // optional
                            },
                            onError: (error) {
                              print("Vdo Error: ${error.message}");
                            },
                          )

                        ),
                      )
                    else
                      Container(
                        height: mediaQuery.height * 0.30,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(20),
                          color: AppColors.white
                              .withOpacity(0.1),
                        ),
                        child: const Center(
                          child: Icon(Icons.music_note,
                              color: Colors.white54,
                              size: 80),
                        ),
                      ),

                    const SizedBox(height: 30),

                    /// 🎵 Song Info
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                playData.title ??
                                    "Unknown Title",
                                style: text24(
                                  color: AppColors.white,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                playData.artist ??
                                    "Unknown Artist",
                                style: text16(
                                    color: AppColors
                                        .textSecondary),
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        /// ❤️ Favorite
                        Obx(() {
                          final isFav = favController.favoriteMap[playData.id] ?? false;

                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : AppColors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              if (playData.id != null) {
                                favController.toggleFavorite(playData.id!);
                              }
                            },
                          );
                        }),

                        /// 🔗 Share
                        IconButton(
                          icon: const Icon(
                            Icons.share_outlined,
                            color: AppColors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Share.share(
                              "🎧 ${playData.title} by ${playData.artist}\n\nWatch now on N Square International!",
                            );
                          },
                        ),
                      ],
                    ),

                    const Spacer(),

                    /// ⚠️ NOTE (Optional UI message)
                    Text(
                      "Secure streaming powered by VdoCipher",
                      style: text12(
                          color:
                          AppColors.textSecondary),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 🎨 Background Gradient
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:video_player/video_player.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/reel_controller/reel_controller.dart';

class ReelPage extends StatefulWidget {
  const ReelPage({super.key});

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> {
  late ReelController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReelController());
  }

  @override
  void dispose() {
    Get.delete<ReelController>(); // 👈 stop video when leaving page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReelController>(
      builder: (_) {
        return Stack(
          children: [
            /// VIDEO
            GestureDetector(
              onTap: controller.togglePlay,
              child: controller.videoController.value.isInitialized
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.videoController.value.size.width,
                          height: controller.videoController.value.size.height,
                          child: VideoPlayer(controller.videoController),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            /// Play icon overlay
            Obx(
              () => controller.isPlaying.value
                  ? const SizedBox()
                  : Center(
                      child: circleIconButton(
                        color: AppColors.white,
                        background: AppColors.white.withAlpha(100),
                        radius: 30,
                        icon: Icons.play_arrow,
                        size: 50,
                        onPressed: () {
                          controller.togglePlay();
                        },
                      ),
                    ),
            ),

            /// Bottom UI
            Obx(
              () => controller.showControls.value
                  ? Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: SafeArea(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            /// Left text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Our Secret | 10 episodes",
                                    style: text20(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Two souls bound by a promise they can’t reveal.",
                                    style: text13(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Right buttons
                            Column(
                              children: [
                                _actionButton(
                                  Icons.bookmark,
                                  "Save",
                                  controller.saveReel,
                                ),
                                const SizedBox(height: 12),
                                _actionButton(
                                  Icons.play_circle_outline,
                                  "Episodes",
                                  controller.goToEpisodes,
                                ),
                                const SizedBox(height: 12),
                                _actionButton(
                                  Icons.share,
                                  "Share",
                                  controller.shareReel,
                                ),
                                const SizedBox(height: 12),
                                Obx(
                                  () => _actionButton(
                                    controller.isMuted.value
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    "Sound",
                                    controller.toggleMute,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        );
      },
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.background.withAlpha(150),
            child: Icon(icon, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: text12(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

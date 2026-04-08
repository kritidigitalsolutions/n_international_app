import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/model/responce/series_res_model/series_res_model.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:video_player/video_player.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/reel_controller/reel_controller.dart';

class ReelPage extends StatefulWidget {
  const ReelPage({super.key});

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> with RouteAware {
  final ReelController controller = Get.put(ReelController());
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void didPushNext() {
    controller.pauseAll(); // jab next page push ho
  }

  @override
  void didPopNext() {
    controller.resumeCurrent(); // jab wapas aaye
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.seriesList.isEmpty) {
          return Center(child: Text("No Reels Available", style: text16(color: Colors.white)));
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: controller.seriesList.length,
          onPageChanged: (index) => controller.onPageChanged(index),
          itemBuilder: (context, index) {
            return ReelItem(series: controller.seriesList[index], index: index);
          },
        );
      }),
    );
  }
}

class ReelItem extends StatefulWidget {
  final Series series;
  final int index;
  const ReelItem({super.key, required this.series, required this.index});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _videoController;
  final ReelController controller = Get.find<ReelController>();

  @override
  void initState() {
    super.initState();
    _videoController = controller.getController(widget.index);
    _videoController.addListener(_videoListener);
    // Play if it's the current one
    if (widget.index == controller.currentIndex.value) {
      _videoController.play();
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _videoController.removeListener(_videoListener);
      _videoController = controller.getController(widget.index);
      _videoController.addListener(_videoListener);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          controller.pauseAll(); // ADD THIS
          Get.toNamed(AppRoutes.seriesDetails, arguments: widget.series);
        }
      },
      onTap: () {
        setState(() {
          if (_videoController.value.isPlaying) {
            _videoController.pause();
          } else {
            _videoController.play();
          }
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// 🎬 Full Screen Video (Reel Format)
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
                : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),

          /// Gradient Overlay for better UI visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// Right Side Action Buttons
          Positioned(
            right: 15,
            bottom: 120,
            child: Column(
              children: [
                // Like icon for reels page
                Obx(() {
                  final isLiked = controller.likedStatus[widget.series.sId!] ?? false;
                  final likeCount = controller.likeCounts[widget.series.sId!] ?? 0;
                  return _actionButton(
                    icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: likeCount.toString(),
                    color: isLiked ? Colors.blue : Colors.white,
                    onTap: () {
                      if (widget.series.sId != null) {
                        controller.toggleLike(widget.series.sId!);
                      }
                    },
                  );
                }),
                const SizedBox(height: 25),
                _actionButton(
                  icon: Icons.share,
                  label: "Share",
                  onTap: () => controller.shareReel(widget.series),
                ),
              ],
            ),
          ),

          /// Bottom Details & Seek Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 80, // Moved up to avoid navigation bar overlap
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.pauseAll();
                    Get.toNamed(AppRoutes.seriesDetails, arguments: widget.series);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.series.title ?? "",
                        style: text24(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.series.description ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text14(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// Seek Bar
                VideoProgressIndicator(
                  _videoController,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.white.withOpacity(0.3),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),

          /// Play Icon Indicator
          if (!_videoController.value.isPlaying)
            Center(
              child: Icon(
                Icons.play_arrow,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, Color color = Colors.white, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 5),
          Text(label, style: text12(color: Colors.white)),
        ],
      ),
    );
  }
}

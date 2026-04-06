import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';
import '../../../model/responce/series_res_model/episode_res_model.dart';
import '../../../model/responce/series_res_model/series_res_model.dart';
import '../../../viewModel/afterLogin/history_controller/histroy_controller.dart';
import '../../../viewModel/afterLogin/SeriesDetail/series_detail_controller.dart';
import '../../../repo/series_repo.dart';

class SeriesPosterPlayerPage extends StatefulWidget {
  const SeriesPosterPlayerPage({super.key});

  @override
  State<SeriesPosterPlayerPage> createState() => _SeriesPosterPlayerPageState();
}

class _SeriesPosterPlayerPageState extends State<SeriesPosterPlayerPage> {
  late PageController _pageController;
  List<Episode> _episodes = [];
  int _currentIndex = 0;
  Series? _series;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;

    if (args is Map) {
      _episodes = args['episodes'] ?? [];
      _currentIndex = args['initialIndex'] ?? 0;
      _series = args['series'];
    }

    _pageController = PageController(initialPage: _currentIndex);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_episodes.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("No episodes found", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _episodes.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return VideoReelItem(
            episode: _episodes[index],
            series: _series,
            isCurrent: _currentIndex == index,
          );
        },
      ),
    );
  }
}

class VideoReelItem extends StatefulWidget {
  final Episode episode;
  final Series? series;
  final bool isCurrent;

  const VideoReelItem({
    super.key,
    required this.episode,
    this.series,
    required this.isCurrent,
  });

  @override
  State<VideoReelItem> createState() => _VideoReelItemState();
}

class _VideoReelItemState extends State<VideoReelItem> {
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = true;
  bool _isError = false;
  final SeriesDetailController _seriesController = Get.find<SeriesDetailController>();
  final HistoryController _historyController = Get.put(HistoryController());
  final SeriesRepo _repo = SeriesRepo();
  int lastSentSecond = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(VideoReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _initializeVideo();
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      _disposeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      // Fetch Like Status for this episode
      _seriesController.getEpisodeLikeStatus(widget.episode.id!);

      // Fetch playback URL from API
      final playData = await _repo.playEpisode(widget.episode.id!);
      String? url = playData.videoPlaybackUrl ?? playData.videoUrl;

      if (url == null || url.isEmpty) {
        throw Exception("Empty video URL");
      }

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();
      _videoPlayerController!.setLooping(true);
      _videoPlayerController!.play();

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController != null &&
            _videoPlayerController!.value.isInitialized &&
            _videoPlayerController!.value.isPlaying) {

          final position = _videoPlayerController!.value.position.inSeconds;
          if (position > 0 && position % 10 == 0 && position != lastSentSecond) {
            lastSentSecond = position;
            _sendHistoryToApi(position);
          }
        }
        if (mounted) setState(() {});
      });

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("❌ Video Error: $e");
      if (mounted) setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  void _sendHistoryToApi(int position) {
    if (widget.series?.sId != null) {
      _historyController.updateWatchHistory(
        seriesId: widget.series!.sId!,
        episodeId: widget.episode.id ?? "",
        progressSeconds: position,
      );
    }
  }

  void _disposeVideo() {
    if (_videoPlayerController != null) {
      _sendHistoryToApi(_videoPlayerController!.value.position.inSeconds);
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (_isError)
            const Center(child: Text("Failed to load video", style: TextStyle(color: Colors.white)))
          else if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _videoPlayerController!.value.isPlaying
                        ? _videoPlayerController!.pause()
                        : _videoPlayerController!.play();
                  });
                },
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoPlayerController!.value.size.width,
                    height: _videoPlayerController!.value.size.height,
                    child: VideoPlayer(_videoPlayerController!),
                  ),
                ),
              ),

          /// 🌫️ Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 🔙 BACK BUTTON
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),

          /// 👉 RIGHT SIDE ACTIONS
          Positioned(
            right: 15,
            bottom: 100,
            child: Column(
              children: [
                // EPISODE LIKE (ThumbUp)
                Obx(() => _actionButton(
                  _seriesController.isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
                  _seriesController.likesCount.value.toString(),
                  color: _seriesController.isLiked.value ? Colors.blue : Colors.white,
                  onTap: () {
                    _seriesController.toggleEpisodeLike(widget.episode.id!);
                  },
                )),
                const SizedBox(height: 25),

                _actionButton(Icons.share, "Share", onTap: () {}),
              ],
            ),
          ),

          /// 📝 BOTTOM DETAILS
          Positioned(
            left: 20,
            right: 80,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.episode.title ?? widget.series?.title ?? "Episode Playing",
                  style: text20(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.episode.description ?? "Enjoy your drama",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text14(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
                if (_videoPlayerController != null)
                  VideoProgressIndicator(
                    _videoPlayerController!,
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

          if (_videoPlayerController != null && !_videoPlayerController!.value.isPlaying && !_isLoading)
            const Center(child: Icon(Icons.play_arrow, size: 80, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, {Color color = Colors.white, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

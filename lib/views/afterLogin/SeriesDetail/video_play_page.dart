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
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;

    if (args is Map) {
      _episodes = args['episodes'] ?? [];
      _currentIndex = args['initialIndex'] ?? 0;
      _series = args['series'];
      _isOffline = args['isOffline'] ?? false;
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
            isOffline: _isOffline,
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
  final bool isOffline;

  const VideoReelItem({
    super.key,
    required this.episode,
    this.series,
    required this.isCurrent,
    this.isOffline = false,
  });

  @override
  State<VideoReelItem> createState() => _VideoReelItemState();
}

class _VideoReelItemState extends State<VideoReelItem> {
  VideoPlayerController? _videoPlayerController;

  /// ✅ RX STATES
  final isLoading = true.obs;
  final isError = false.obs;
  final isLocked = false.obs;
  final isPlaying = false.obs;
  final isMuted = false.obs;

  late final SeriesDetailController _seriesController;
  late final HistoryController _historyController;

  final SeriesRepo _repo = SeriesRepo();
  int lastSentSecond = 0;
  Worker? _unlockWorker;

  @override
  void initState() {
    super.initState();

    _seriesController = Get.isRegistered<SeriesDetailController>()
        ? Get.find<SeriesDetailController>()
        : Get.put(SeriesDetailController());

    _historyController = Get.isRegistered<HistoryController>()
        ? Get.find<HistoryController>()
        : Get.put(HistoryController());

    if (widget.isCurrent) {
      _initializeVideo();
    }

    _unlockWorker = ever(_seriesController.locallyUnlockedIds, (ids) {
      if (widget.isCurrent && isLocked.value && ids.contains(widget.episode.id)) {
        _initializeVideo();
      }
    });
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

    bool alreadyUnlocked = widget.episode.alreadyUnlocked == true || 
                          _seriesController.locallyUnlockedIds.contains(widget.episode.id) ||
                          widget.episode.isLocked == false;

    if (!alreadyUnlocked && !widget.isOffline) {
      isLoading.value = false;
      isLocked.value = true;
      isError.value = false;
      return;
    }

    isLocked.value = false;
    isLoading.value = true;
    isError.value = false;

    try {
      String? url;

      if (widget.isOffline) {
        url = widget.episode.videoUrl;
        if (url == null || url.isEmpty) throw Exception("Local path missing");
        _videoPlayerController = VideoPlayerController.file(File(url));
      } else {
        _seriesController.getEpisodeLikeStatus(widget.episode.id!);
        final playData = await _repo.playEpisode(widget.episode.id!);
        url = playData.videoPlaybackUrl ?? playData.videoUrl;
        if (url == null || url.isEmpty) throw Exception("Empty URL");
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      }

      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      await _videoPlayerController!.play();
      
      _videoPlayerController!.setVolume(isMuted.value ? 0 : 1.0);
      isPlaying.value = true;

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController == null) return;
        final controller = _videoPlayerController!;
        
        // Sync play state
        if (isPlaying.value != controller.value.isPlaying) {
          isPlaying.value = controller.value.isPlaying;
        }

        if (controller.value.isInitialized && controller.value.isPlaying) {
          final position = controller.value.position.inSeconds;
          if (!widget.isOffline && position > 0 && position % 10 == 0 && position != lastSentSecond) {
            lastSentSecond = position;
            _sendHistoryToApi(position);
          }
        }
      });

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      if (e.toString().toLowerCase().contains("lock") || e.toString().contains("403")) {
        isLocked.value = true;
      } else {
        isError.value = true;
      }
    }
  }

  void _sendHistoryToApi(int position) {
    if (!widget.isOffline && widget.series?.sId != null) {
      _historyController.updateWatchHistory(
        seriesId: widget.series!.sId!,
        episodeId: widget.episode.id ?? "",
        progressSeconds: position,
      );
    }
  }

  void _disposeVideo() {
    if (_videoPlayerController != null) {
      if (!widget.isOffline) {
        _sendHistoryToApi(_videoPlayerController!.value.position.inSeconds);
      }
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }

  @override
  void dispose() {
    _unlockWorker?.dispose();
    _disposeVideo();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;
    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
      isPlaying.value = false;
    } else {
      _videoPlayerController!.play();
      isPlaying.value = true;
    }
    setState(() {}); // For instant UI feedback
  }

  void _toggleMute() {
    if (_videoPlayerController == null) return;
    isMuted.value = !isMuted.value;
    _videoPlayerController!.setVolume(isMuted.value ? 0 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return Stack(
          fit: StackFit.expand,
          children: [
            /// 🎬 VIDEO PLAYER
            if (isLoading.value)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (isLocked.value)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: Colors.white, size: 50),
                    const SizedBox(height: 10),
                    const Text("Episode Locked", style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () {
                        if (widget.series?.sId != null && widget.episode.id != null) {
                          _seriesController.unlockEpisode(widget.series!.sId!, widget.episode.id!);
                        }
                      },
                      child: const Text("Unlock ₹1", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              )
            else if (isError.value)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 50),
                    const SizedBox(height: 10),
                    const Text("Failed to load video", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _initializeVideo, child: const Text("Retry"))
                  ],
                ),
              )
            else if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoPlayerController!.value.size.width,
                        height: _videoPlayerController!.value.size.height,
                        child: VideoPlayer(_videoPlayerController!),
                      ),
                    ),
                  ),
                ),

            /// 🌫 GRADIENT OVERLAY (Wrapped in IgnorePointer to fix play/pause taps)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
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

            /// 🛠 ACTION BUTTONS (LIKE, MUTE, SHARE)
            Positioned(
              right: 15,
              bottom: 100,
              child: Column(
                children: [
                  if (!widget.isOffline) ...[
                    Obx(() => _actionButton(
                      _seriesController.isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
                      _seriesController.likesCount.value.toString(),
                      color: _seriesController.isLiked.value ? Colors.blue : Colors.white,
                      onTap: () => _seriesController.toggleEpisodeLike(widget.episode.id!),
                    )),
                    const SizedBox(height: 25),
                  ],
                  // ✅ MUTE/UNMUTE BUTTON
                  Obx(() => _actionButton(
                    isMuted.value ? Icons.volume_off : Icons.volume_up,
                    isMuted.value ? "Muted" : "Mute",
                    onTap: _toggleMute,
                  )),
                  const SizedBox(height: 25),
                  _actionButton(Icons.share, "Share"),
                ],
              ),
            ),

            /// 📝 TITLE & PROGRESS
            Positioned(
              left: 20,
              right: 80,
              bottom: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.episode.title ?? widget.series?.title ?? "Episode Playing", style: text20(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.episode.description ?? "Enjoy your drama", maxLines: 2, overflow: TextOverflow.ellipsis, style: text14(color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 20),
                  if (_videoPlayerController != null)
                    AnimatedBuilder(
                      animation: _videoPlayerController!,
                      builder: (context, child) {
                        return VideoProgressIndicator(
                          _videoPlayerController!,
                          allowScrubbing: true,
                          colors: VideoProgressColors(playedColor: AppColors.primary, bufferedColor: Colors.white.withOpacity(0.3), backgroundColor: Colors.white.withOpacity(0.2)),
                        );
                      },
                    ),
                ],
              ),
            ),

            /// ▶ PLAY ICON (When paused)
            if (!isPlaying.value && !isLoading.value && !isError.value && !isLocked.value)
              const Center(child: Icon(Icons.play_arrow, size: 80, color: Colors.white54)),
          ],
        );
      }),
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
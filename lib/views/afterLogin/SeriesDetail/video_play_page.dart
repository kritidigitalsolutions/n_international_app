import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../model/responce/series_res_model/play_episode_res_model.dart';
import '../../../viewModel/afterLogin/history_controller/histroy_controller.dart';
import '../../../viewModel/afterLogin/SeriesDetail/series_detail_controller.dart';

class SeriesPosterPlayerPage extends StatefulWidget {
  const SeriesPosterPlayerPage({super.key});

  @override
  State<SeriesPosterPlayerPage> createState() =>
      _SeriesPosterPlayerPageState();
}

class _SeriesPosterPlayerPageState extends State<SeriesPosterPlayerPage> {
  final HistoryController _historyController = Get.put(HistoryController());
  late SeriesDetailController _seriesController;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _isLoading = true;
  String? seriesId;
  int lastSentSecond = 0;

  @override
  void initState() {
    super.initState();
    _seriesController = Get.put(SeriesDetailController());

    // Lock to Portrait for Reel-style feel
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final args = Get.arguments;
    String playbackUrl = "";

    // 👉 Handle Model Arguments (From Series Detail)
    if (args is PlayEpisodeResModel) {
      playbackUrl = args.videoPlaybackUrl ?? args.videoUrl ?? "";
      seriesId = args.videoId ?? args.seriesId;
    }
    // 👉 Handle Map Arguments (From History or Downloads)
    else if (args is Map) {
      playbackUrl =
          args["filePath"] ?? // ✅ OFFLINE
              args["videoUrl"] ??
              args["videoPlaybackUrl"] ??
              "";

      seriesId = args["seriesId"] ?? args["id"];
    }

    if (seriesId != null && seriesId!.isNotEmpty) {
      _seriesController.checkIsFavorite(seriesId!);
    }

    initializePlayer(playbackUrl);
  }

  Future<void> initializePlayer(String url) async {
    if (url.isEmpty) return;
    if (mounted) setState(() => _isLoading = true);

    try {
      // Clean up existing controllers
      await _videoPlayerController?.dispose();
      _chewieController?.dispose();

      // ✅ FIX: Detect if URL is a local file path (Downloads)
      bool isLocalFile = url.startsWith('/') ||
          url.contains('app_flutter') ||
          !url.startsWith('http');

      if (isLocalFile) {
        debugPrint("🚀 Playing Local Offline File: $url");
        _videoPlayerController = VideoPlayerController.file(File(url));
      } else {
        debugPrint("🌐 Playing Network Stream: $url");
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      await _videoPlayerController!.initialize();

      /// ✅ LISTENER FOR HISTORY TRACKING
      _videoPlayerController!.addListener(() {
        if (_videoPlayerController != null &&
            _videoPlayerController!.value.isInitialized &&
            _videoPlayerController!.value.isPlaying) {

          final position = _videoPlayerController!.value.position.inSeconds;

          // Sync progress every 10 seconds
          if (position > 0 && position % 10 == 0 && position != lastSentSecond) {
            lastSentSecond = position;
            _sendHistoryToApi(position);
          }
        }
      });

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.portraitUp],
        allowMuting: true,
        showControls: false, // Using custom UI overlays below
      );
    } catch (e) {
      debugPrint("❌ Video Init Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper to extract IDs and send history
  void _sendHistoryToApi(int position) {
    final dynamic data = Get.arguments;
    String sId = "";
    String eId = "";

    if (data is PlayEpisodeResModel) {
      sId = data.videoId ?? data.seriesId ?? "";
      eId = data.episodeId ?? "";
    } else if (data is Map) {
      sId = data["seriesId"] ?? "";
      eId = data["episodeId"] ?? "";
    }

    if (sId.isNotEmpty) {
      debugPrint("⏱ Sending History: $position sec for Series: $sId");
      _historyController.updateWatchHistory(
        seriesId: sId,
        episodeId: eId,
        progressSeconds: position,
      );
    }
  }

  @override
  void dispose() {
    // ✅ FINAL PROGRESS SAVE ON CLOSE
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      _sendHistoryToApi(_videoPlayerController!.value.position.inSeconds);
    }

    // Reset Orientation settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Widget _buildAction(IconData icon, String label, {Color color = Colors.white, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _chewieController != null &&
          _videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized
          ? Stack(
        children: [
          /// 🎬 FULL SCREEN VIDEO
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPlayerController!.value.size.width,
                height: _videoPlayerController!.value.size.height,
                child: Chewie(controller: _chewieController!),
              ),
            ),
          ),

          /// ▶ TAP TO PLAY / PAUSE
          GestureDetector(
            onTap: () {
              setState(() {
                _videoPlayerController!.value.isPlaying
                    ? _videoPlayerController!.pause()
                    : _videoPlayerController!.play();
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: !_videoPlayerController!.value.isPlaying
                    ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
                )
                    : const SizedBox(),
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

          /// 👉 RIGHT SIDE ACTIONS (Favorite, Episodes, etc)
          Positioned(
            right: 15,
            bottom: 120,
            child: Column(
              children: [
                Obx(() => _buildAction(
                  _seriesController.isFavorite.value ? Icons.bookmark : Icons.bookmark_border,
                  "Save",
                  color: _seriesController.isFavorite.value ? Colors.red : Colors.white,
                  onTap: () {
                    if (seriesId != null) {
                      _seriesController.toggleFavorite(seriesId!);
                    }
                  },
                )),
                const SizedBox(height: 25),
                _buildAction(Icons.play_circle_outline, "Episode"),
                const SizedBox(height: 25),
                _buildAction(Icons.volume_up, "Sound"),
              ],
            ),
          ),

          /// ⏱ PROGRESS BAR
          Positioned(
            left: 15,
            right: 15,
            bottom: 40,
            child: VideoProgressIndicator(
              _videoPlayerController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      )
          : const Center(
        child: Text("Failed to load video", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../model/responce/series_res_model/play_episode_res_model.dart';

class SeriesPosterPlayerPage extends StatefulWidget {
  const SeriesPosterPlayerPage({super.key});

  @override
  State<SeriesPosterPlayerPage> createState() =>
      _SeriesPosterPlayerPageState();
}

class _SeriesPosterPlayerPageState extends State<SeriesPosterPlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    final PlayEpisodeResModel data = Get.arguments;
    String playbackUrl = data.videoPlaybackUrl ?? data.videoUrl ?? "";

    initializePlayer(playbackUrl);
  }

  Future<void> initializePlayer(String url) async {
    if (url.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _videoPlayerController?.dispose();
      _chewieController?.dispose();

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.portraitUp],
        allowMuting: true,
        showControls: false, // ❗ hide default controls (important)
      );
    } catch (e) {
      debugPrint("Video Init Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  /// 👉 Action Button Widget
  Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
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
          /// 🎬 FULL SCREEN VIDEO (REELS STYLE)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width:
                _videoPlayerController!.value.size.width,
                height:
                _videoPlayerController!.value.size.height,
                child: Chewie(controller: _chewieController!),
              ),
            ),
          ),

          /// 🖐 TAP PLAY/PAUSE
          GestureDetector(
            onTap: () {
              final isPlaying =
                  _videoPlayerController!.value.isPlaying;
              setState(() {
                isPlaying
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
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
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
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),

          /// 👉 RIGHT SIDE ACTIONS
          Positioned(
            right: 10,
            bottom: 120,
            child: Column(
              children: [
                _buildAction(Icons.bookmark_border, "Save"),
                const SizedBox(height: 20),
                _buildAction(
                    Icons.play_circle_outline, "Episode"),
                const SizedBox(height: 20),
                _buildAction(Icons.volume_up, "Sound"),
              ],
            ),
          ),

          /// 📝 DESCRIPTION
          Positioned(
            left: 10,
            right: 80,
            bottom: 70,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: const [
                Text(
                  "The Last Kingdom - Episode 1",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Uhtred begins his journey in this epic historical drama...",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          /// ⏱ SEEK BAR
          Positioned(
            left: 10,
            right: 10,
            bottom: 40,
            child: VideoProgressIndicator(
              _videoPlayerController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      )
          : const Center(
        child: Text(
          "Failed to load video",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

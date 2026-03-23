import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for orientation
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../model/responce/series_res_model/play_episode_res_model.dart';

class SeriesPosterPlayerPage extends StatefulWidget {
  const SeriesPosterPlayerPage({super.key});

  @override
  State<SeriesPosterPlayerPage> createState() => _SeriesPosterPlayerPageState();
}

class _SeriesPosterPlayerPageState extends State<SeriesPosterPlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 1. Force Vertical Orientation when entering
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
        // 2. Lock Aspect Ratio to the Container (Vertical)
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,

        // 3. Prevent Chewie from auto-rotating to landscape on fullscreen
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.portraitUp],

        allowMuting: true,
        showControls: true,
        placeholder: const Center(child: CircularProgressIndicator(color: Colors.red)),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 42),
                const SizedBox(height: 10),
                const Text(
                  "Playback Error\nLink might be expired or restricted",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () => initializePlayer(url),
                  child: const Text("Retry", style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
          );
        },
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
    // 4. Reset Orientation to allow rotation again when leaving the player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.red)
                  : _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
                  ? AspectRatio(
                // Wrap in AspectRatio to maintain vertical framing
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
                  : const Text(
                "Failed to load video",
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
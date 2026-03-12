import 'dart:async';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ReelController extends GetxController {
  late VideoPlayerController videoController;

  var isPlaying = true.obs;
  var isMuted = false.obs;
  var showControls = true.obs;

  Timer? _hideTimer;

  @override
  void onInit() {
    super.onInit();

    videoController = VideoPlayerController.asset("assets/video/reel.mp4")
      ..initialize().then((_) {
        videoController.setLooping(true);
        videoController.play();
        startHideTimer();
        update();
      });
  }

  /// Start auto hide timer
  void startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      showControls.value = false;
    });
  }

  /// Toggle controls on tap
  void toggleControls() {
    showControls.value = !showControls.value;

    if (showControls.value) {
      startHideTimer();
    }
  }

  void togglePlay() {
    if (videoController.value.isPlaying) {
      videoController.pause();
      isPlaying.value = false;
      toggleControls();
    } else {
      videoController.play();
      isPlaying.value = true;
    }
  }

  void toggleMute() {
    if (isMuted.value) {
      videoController.setVolume(1);
      isMuted.value = false;
    } else {
      videoController.setVolume(0);
      isMuted.value = true;
    }
  }

  @override
  void onClose() {
    _hideTimer?.cancel();
    videoController.pause();
    videoController.dispose();
    super.onClose();
  }

  void saveReel() {
    Get.snackbar("Saved", "Reel saved to bookmarks");
  }

  void goToEpisodes() {
    Get.snackbar("Episodes", "Opening episodes...");
  }

  void shareReel() {
    Get.snackbar("Share", "Sharing reel...");
  }
}

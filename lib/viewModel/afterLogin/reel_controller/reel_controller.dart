import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ReelController extends GetxController {
  late VideoPlayerController videoController;

  var isPlaying = true.obs;
  var isMuted = false.obs;

  @override
  void onInit() {
    super.onInit();

    videoController =
        VideoPlayerController.networkUrl(
            Uri.parse(
              "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
            ),
          )
          ..initialize().then((_) {
            videoController.setLooping(true);
            videoController.play();
            update();
          });
  }

  void togglePlay() {
    if (videoController.value.isPlaying) {
      videoController.pause();
      isPlaying.value = false;
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

  void saveReel() {
    Get.snackbar("Saved", "Reel saved to bookmarks");
  }

  void goToEpisodes() {
    Get.snackbar("Episodes", "Opening episodes...");
  }

  void shareReel() {
    Get.snackbar("Share", "Sharing reel...");
  }

  @override
  void onClose() {
    videoController.pause();
    videoController.dispose();
    super.onClose();
  }
}

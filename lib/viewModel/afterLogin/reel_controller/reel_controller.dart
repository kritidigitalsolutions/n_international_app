import 'package:get/get.dart';
import 'package:n_square_international/model/responce/series_res_model/series_res_model.dart';
import 'package:n_square_international/repo/series_repo.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

class ReelController extends GetxController {
  final SeriesRepo _repo = SeriesRepo();

  var seriesList = <Series>[].obs;
  var isLoading = true.obs;
  var currentIndex = 0.obs;

  // Like state for each reel (using series ID)
  var likedStatus = <String, bool>{}.obs;
  var likeCounts = <String, int>{}.obs;

  final Map<int, VideoPlayerController> controllers = {};

  @override
  void onInit() {
    super.onInit();
    fetchReels();
  }

  Future<void> fetchReels() async {
    try {
      isLoading.value = true;
      final response = await _repo.fetchSeries(page: 1, limit: 50);
      if (response.series != null) {
        var list = response.series!.where((s) => s.trailerUrl != null && s.trailerUrl!.isNotEmpty).toList();
        list.shuffle();
        seriesList.value = list;

        // Initialize likes for the list
        for (var series in list) {
          if (series.sId != null) {
            likedStatus[series.sId!] = false;
            likeCounts[series.sId!] = 0;
          }
        }
      }
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      isLoading.value = false;
    }
  }

  VideoPlayerController getController(int index) {
    if (controllers.containsKey(index)) {
      return controllers[index]!;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(seriesList[index].trailerUrl ?? ""),
    )..initialize().then((_) {
      update();
    });
    controller.setLooping(true);
    controllers[index] = controller;
    return controller;
  }

  void onPageChanged(int index) {
    controllers[currentIndex.value]?.pause();
    currentIndex.value = index;
    getController(index).play();

    if (index + 1 < seriesList.length) {
      getController(index + 1);
    }

    controllers.keys.toList().forEach((key) {
      if ((key - index).abs() > 2) {
        controllers[key]?.dispose();
        controllers.remove(key);
      }
    });
  }

  void pauseAll() {
    for (var controller in controllers.values) {
      controller.pause();
    }
  }

  void resumeCurrent() {
    if (controllers.containsKey(currentIndex.value)) {
      controllers[currentIndex.value]!.play();
    }
  }

  @override
  void onClose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  void shareReel(Series series) {
    Share.share("Check out this amazing series: ${series.title}\nWatch it on N Square International: ${series.trailerUrl}");
  }

  // Reels are currently trailers of series, so we toggle like based on series ID
  // Note: Using a generic 'like' method for reels.
  Future<void> toggleLike(String seriesId) async {
    try {
      bool currentStatus = likedStatus[seriesId] ?? false;
      if (currentStatus) {
        likedStatus[seriesId] = false;
        likeCounts[seriesId] = (likeCounts[seriesId] ?? 1) - 1;
      } else {
        likedStatus[seriesId] = true;
        likeCounts[seriesId] = (likeCounts[seriesId] ?? 0) + 1;
      }
      likedStatus.refresh();
      likeCounts.refresh();
    } catch (e) {
      print("Error toggling like on reel: $e");
    }
  }

  Future<void> toggleFavorite(String seriesId) async {
    try {
      // Reuse the existing favorite logic from repo
      await _repo.addFavorite(seriesId);
    } catch (e) {
      print("Error toggling favorite on reel: $e");
    }
  }
}

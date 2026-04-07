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

  // Like state for each reel (using series ID as key)
  var likedStatus = <String, bool>{}.obs;
  var likeCounts = <String, int>{}.obs;
  
  // Cache for first episode ID of each series to avoid redundant API calls
  final Map<String, String> _seriesFirstEpisodeIdCache = {};

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

        // Fetch initial status for the first reel
        if (list.isNotEmpty && list[0].sId != null) {
          _fetchInitialLikeStatus(list[0].sId!);
        }
      }
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _getFirstEpisodeId(String seriesId) async {
    if (_seriesFirstEpisodeIdCache.containsKey(seriesId)) {
      return _seriesFirstEpisodeIdCache[seriesId];
    }
    try {
      final episodeData = await _repo.fetchEpisodes(seriesId);
      if (episodeData.episodes != null && episodeData.episodes!.isNotEmpty) {
        final id = episodeData.episodes![0].id!;
        _seriesFirstEpisodeIdCache[seriesId] = id;
        return id;
      }
    } catch (e) {
      print("Error fetching episode for like: $e");
    }
    return null;
  }
  
  Future<void> _fetchInitialLikeStatus(String seriesId) async {
    try {
      final episodeId = await _getFirstEpisodeId(seriesId);
      if (episodeId != null) {
        final response = await _repo.getLikeStatus(episodeId);
        if (response['success'] == true && response['like'] != null) {
          likedStatus[seriesId] = response['like']['liked'] ?? false;
          likeCounts[seriesId] = response['like']['likesCount'] ?? 0;
          likedStatus.refresh();
          likeCounts.refresh();
        }
      }
    } catch (e) {
      print("Error fetching initial like status for $seriesId: $e");
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

    // Lazy load like status for current and next reel
    if (seriesList[index].sId != null) {
      _fetchInitialLikeStatus(seriesList[index].sId!);
    }
    if (index + 1 < seriesList.length && seriesList[index + 1].sId != null) {
      _fetchInitialLikeStatus(seriesList[index + 1].sId!);
    }

    if (index + 1 < seriesList.length) {
      getController(index + 1);
    }

    // Clean up memory
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

  Future<void> toggleLike(String seriesId) async {
    try {
      final episodeId = await _getFirstEpisodeId(seriesId);
      if (episodeId == null) return;
      
      bool currentStatus = likedStatus[seriesId] ?? false;

      if (currentStatus) {
        final response = await _repo.dislikeEpisode(episodeId);
        if (response['success'] == true) {
          likedStatus[seriesId] = false;
          if (response['likesCount'] != null) {
            likeCounts[seriesId] = response['likesCount'];
          } else {
            likeCounts[seriesId] = (likeCounts[seriesId] ?? 1) - 1;
          }
        }
      } else {
        final response = await _repo.likeEpisode(episodeId);
        if (response['success'] == true) {
          likedStatus[seriesId] = true;
          if (response['likesCount'] != null) {
            likeCounts[seriesId] = response['likesCount'];
          } else {
            likeCounts[seriesId] = (likeCounts[seriesId] ?? 0) + 1;
          }
        }
      }
      likedStatus.refresh();
      likeCounts.refresh();
    } catch (e) {
      print("Error toggling like on reel: $e");
    }
  }
}

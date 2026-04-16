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
  var isMuted = false.obs; // ✅ Global mute state for reels

  var likedStatus = <String, bool>{}.obs;
  var likeCounts = <String, int>{}.obs;
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

  void toggleMute() {
    isMuted.value = !isMuted.value;
    controllers.values.forEach((c) => c.setVolume(isMuted.value ? 0 : 1.0));
  }

  VideoPlayerController getController(int index) {
    if (controllers.containsKey(index)) {
      return controllers[index]!;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(seriesList[index].trailerUrl ?? ""));
    controller.initialize().then((_) {
      controller.setVolume(isMuted.value ? 0 : 1.0);
      update();
    });
    controller.setLooping(true);
    controllers[index] = controller;
    return controller;
  }

  void onPageChanged(int index) {
    controllers[currentIndex.value]?.pause();
    currentIndex.value = index;
    final newController = getController(index);
    newController.setVolume(isMuted.value ? 0 : 1.0);
    newController.play();
    if (seriesList[index].sId != null) _fetchInitialLikeStatus(seriesList[index].sId!);
    if (index + 1 < seriesList.length) getController(index + 1);
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
      controllers[currentIndex.value]!.setVolume(isMuted.value ? 0 : 1.0);
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
    } catch (e) {}
  }

  Future<String?> _getFirstEpisodeId(String seriesId) async {
    if (_seriesFirstEpisodeIdCache.containsKey(seriesId)) return _seriesFirstEpisodeIdCache[seriesId];
    try {
      final episodeData = await _repo.fetchEpisodes(seriesId);
      if (episodeData.episodes != null && episodeData.episodes!.isNotEmpty) {
        final id = episodeData.episodes![0].id!;
        _seriesFirstEpisodeIdCache[seriesId] = id;
        return id;
      }
    } catch (e) {}
    return null;
  }

  void shareReel(Series series) {
    Share.share("Check out this amazing series: ${series.title}\nWatch it on N2 Shorts: ${series.trailerUrl}");
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
          likeCounts[seriesId] = response['likesCount'] ?? (likeCounts[seriesId] ?? 1) - 1;
        }
      } else {
        final response = await _repo.likeEpisode(episodeId);
        if (response['success'] == true) {
          likedStatus[seriesId] = true;
          likeCounts[seriesId] = response['likesCount'] ?? (likeCounts[seriesId] ?? 0) + 1;
        }
      }
      likedStatus.refresh();
      likeCounts.refresh();
    } catch (e) {}
  }
}
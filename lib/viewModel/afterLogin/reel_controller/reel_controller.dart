import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/model/responce/series_res_model/series_res_model.dart';
import 'package:n_square_international/repo/series_repo.dart';
import 'package:n_square_international/viewModel/afterLogin/home_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

class ReelController extends GetxController {
  final SeriesRepo _repo = SeriesRepo();
  final HomeController homeController = Get.find<HomeController>();

  var allReels = <Series>[].obs;
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
    _initAudioSession();
    fetchReels();
    // Listen to language changes from HomeController
    ever(homeController.selectedLanguage, (_) {
      applyLanguageFilter();
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> fetchReels() async {
    try {
      isLoading.value = true;
      final response = await _repo.fetchSeries(page: 1, limit: 50);
      if (response.series != null) {
        var list = response.series!.where((s) => s.trailerUrl != null && s.trailerUrl!.isNotEmpty).toList();
        allReels.assignAll(list);
        applyLanguageFilter();
      }
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyLanguageFilter() {
    String selectedLang = homeController.selectedLanguage.value;
    List<Series> filteredList = allReels;

    if (selectedLang != 'All') {
      filteredList = allReels.where((s) {
        return s.languages?.any((lang) =>
                lang.toLowerCase() == selectedLang.toLowerCase()) ??
            false;
      }).toList();
    }

    // Pause and collect old controllers to dispose them after the UI updates
    final oldControllers = Map<int, VideoPlayerController>.from(controllers);
    controllers.clear();
    currentIndex.value = 0;

    var listToAssign = List<Series>.from(filteredList);
    // Only shuffle if there's actually something to show
    if (listToAssign.isNotEmpty) {
      listToAssign.shuffle();
    }
    seriesList.assignAll(listToAssign);

    // Dispose old controllers after the next frame to avoid "used after disposed" errors in UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var c in oldControllers.values) {
        c.dispose();
      }
    });

    if (seriesList.isNotEmpty && seriesList[0].sId != null) {
      _fetchInitialLikeStatus(seriesList[0].sId!);
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

  void onPageChanged(int index) async {
    controllers[currentIndex.value]?.pause();
    currentIndex.value = index;
    final newController = getController(index);
    newController.setVolume(isMuted.value ? 0 : 1.0);
    
    // Request audio focus before playing
    final session = await AudioSession.instance;
    if (await session.setActive(true)) {
      newController.play();
    }
    
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

  void resumeCurrent() async {
    if (controllers.containsKey(currentIndex.value)) {
      final session = await AudioSession.instance;
      if (await session.setActive(true)) {
        controllers[currentIndex.value]!.setVolume(isMuted.value ? 0 : 1.0);
        controllers[currentIndex.value]!.play();
      }
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
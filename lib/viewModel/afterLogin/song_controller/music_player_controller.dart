import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/api_responce_data.dart';
import '../../../model/responce/audio_res_model/song_play_res_model.dart';
import '../../../model/responce/audio_res_model/song_res_model.dart';
import '../../../repo/audio_repo.dart';

class MusicPlayerController extends GetxController {
  final AudioRepo _repo = AudioRepo();

  final AudioPlayer audioPlayer = AudioPlayer();

  /// API
  var songPlayResponse = ApiResponse<SongPlayResModel>.loading().obs;
  var currentSong = Rxn<Song>();

  /// Player State
  var isPlaying = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();

    /// Get Song
    if (Get.arguments is Song) {
      currentSong.value = Get.arguments as Song;

      if (currentSong.value?.id != null) {
        fetchSongPlayData(currentSong.value!.id!);
      }
    }

    /// Listen state
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    audioPlayer.durationStream.listen((d) {
      if (d != null && d.inSeconds > 0) {
        duration.value = d;
      }
    });

    audioPlayer.positionStream.listen((p) {
      position.value = p;
    });
  }

  Future<void> fetchSongPlayData(String songId) async {
    songPlayResponse.value = ApiResponse.loading();

    try {
      final response = await _repo.getSongPlayData(songId);

      if (response.success == true) {
        songPlayResponse.value = ApiResponse.completed(response);

        final audioUrl =
            response.playData?.audioPlaybackUrl ??
                response.playData?.audioUrl;

        if (audioUrl != null) {
          await playSong(audioUrl);
        }
      } else {
        songPlayResponse.value =
            ApiResponse.error(response.message ?? "Error");
      }
    } catch (e) {
      songPlayResponse.value =
          ApiResponse.error("Something went wrong: $e");
    }
  }

  Future<void> playSong(String url) async {
    await audioPlayer.setUrl(url);
    audioPlayer.play();
  }

  void pauseSong() => audioPlayer.pause();

  void seek(Duration position) => audioPlayer.seek(position);

  String formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}

import 'package:get/get.dart';
import '../../../data/api_responce_data.dart';
import '../../../model/responce/audio_res_model/song_play_res_model.dart';
import '../../../model/responce/audio_res_model/song_res_model.dart';
import '../../../repo/audio_repo.dart';

class MusicPlayerController extends GetxController {
  final AudioRepo _repo = AudioRepo();

  /// API Response
  var songPlayResponse = ApiResponse<SongPlayResModel>.loading().obs;

  /// Current Song
  var currentSong = Rxn<Song>();

  @override
  void onInit() {
    super.onInit();

    /// Get Song from previous screen
    if (Get.arguments is Song) {
      currentSong.value = Get.arguments as Song;

      /// Fetch Play Data
      if (currentSong.value?.id != null) {
        fetchSongPlayData(currentSong.value!.id!);
      }
    }
  }

  /// Fetch Song Play Data (VdoCipher)
  Future<void> fetchSongPlayData(String songId) async {
    songPlayResponse.value = ApiResponse.loading();

    try {
      final response = await _repo.getSongPlayData(songId);

      if (response.success == true) {
        songPlayResponse.value = ApiResponse.completed(response);
      } else {
        songPlayResponse.value =
            ApiResponse.error(response.message ?? "Failed to load song");
      }
    } catch (e) {
      songPlayResponse.value =
          ApiResponse.error("Something went wrong: $e");
    }
  }
}

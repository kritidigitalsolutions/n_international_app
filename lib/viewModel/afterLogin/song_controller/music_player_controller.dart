import 'dart:io';
import 'package:flutter/material.dart';
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
  var duration = Rx<Duration>(Duration.zero);
  var position = Rx<Duration>(Duration.zero);

  @override
  void onInit() {
    super.onInit();
    handleArguments();
    setupListeners();
  }
  void handleArguments() {
    final args = Get.arguments;
    print("🎵 HANDLE ARGUMENTS: $args");

    if (args == null) return;

    if (args is Map) {
      currentSong.value = args["song"] ??
          Song(
            id: args["id"],
            title: args["title"],
            thumbnail: args["image"],
          );

      String? filePath = args["filePath"];
      String? url = args["url"];
      String? id = args["id"];

      /// 🎵 OFFLINE
      if (filePath != null && filePath.isNotEmpty) {
        print("🚀 OFFLINE: $filePath");

        songPlayResponse.value = ApiResponse.completed(
          SongPlayResModel(
            success: true,
            playData: PlayData(
              id: id,
              title: currentSong.value?.title,
              artist: args["artist"],
              audioUrl: filePath,
              audioPlaybackUrl: filePath,
              thumbnailUrl: args["image"] ?? currentSong.value?.thumbnail,
              thumbnailPlaybackUrl: args["image"] ?? currentSong.value?.thumbnail,
            ),
          ),
        );

        playSong(filePath);
        return;
      }

      /// 🌐 ONLINE DIRECT URL
      if (url != null && url.isNotEmpty) {
        print("🌐 ONLINE URL: $url");

        songPlayResponse.value = ApiResponse.completed(
          SongPlayResModel(
            success: true,
            playData: PlayData(
              id: id,
              title: currentSong.value?.title,
              artist: args["artist"],
              audioUrl: url,
              audioPlaybackUrl: url,
              thumbnailUrl: args["image"],
              thumbnailPlaybackUrl: args["image"],
            ),
          ),
        );

        playSong(url);
        return;
      }

      /// 📡 API CALL
      if (id != null) {
        fetchSongPlayData(id);
        return;
      }
    }

    /// 🎧 NORMAL SONG
    else if (args is Song) {
      currentSong.value = args;

      if (args.id != null) {
        fetchSongPlayData(args.id!);
      }
    }
  }


  // void handleArguments() {
  //   final args = Get.arguments;
  //
  //   if (args == null) return;
  //
  //   if (args is Song) {
  //     currentSong.value = args;
  //
  //     if (args.id != null) {
  //       fetchSongPlayData(args.id!);
  //     }
  //   }
  // }

  /// ✅ 2. Fix Player Listeners
  void setupListeners() {
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
      }
    });

    audioPlayer.durationStream.listen((d) {
      if (d != null) duration.value = d;
    });

    audioPlayer.positionStream.listen((p) {
      position.value = p;
    });
  }

  /// ✅ 3. Fix API Call & URL Priority
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

  /// ✅ 4. Fix Play Function (Instant Local Play)
  Future<void> playSong(String path) async {
    print("🎧 PLAY REQUEST: $path");

    try {
      if (path.startsWith("/")) {
        /// ✅ LOCAL FILE
        print("📁 LOCAL FILE PLAY");
        await audioPlayer.setFilePath(path);
      } else {
        /// 🌐 NETWORK
        print("🌐 NETWORK PLAY");
        await audioPlayer.setUrl(path);
      }

      audioPlayer.play();
    } catch (e) {
      print("❌ AUDIO ERROR: $e");
    }
  }

  // Future<void> playSong(String url) async {
  //   print("🎧 PLAYING URL: $url");
  //
  //   try {
  //     await audioPlayer.setUrl(url);
  //     audioPlayer.play();
  //   } catch (e) {
  //     print("❌ AUDIO ERROR: $e");
  //   }
  // }

  void togglePlayPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  void seek(Duration pos) => audioPlayer.seek(pos);

  String formatTime(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
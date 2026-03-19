import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vdocipher_flutter/vdocipher_flutter.dart';
import '../../../model/responce/series_res_model/play_episode_res_model.dart';

class SeriesPosterPlayerPage extends StatelessWidget {
  const SeriesPosterPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {

    final PlayEpisodeResModel data = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [

            /// 🎬 VDO PLAYER
            VdoPlayer(
              embedInfo: EmbedInfo.streaming(
                otp: data.otp ?? "",
                playbackInfo: data.playbackInfo ?? "",
              ),
              onPlayerCreated: (VdoPlayerController controller) {
                // optional controls
              },
              onError: (error) {
                print("VIDEO ERROR: $error");
              },
            ),


            /// 🔙 BACK BUTTON
            // Positioned(
            //   top: 20,
            //   left: 10,
            //   child: IconButton(
            //     icon: const Icon(Icons.arrow_back, color: Colors.white),
            //     onPressed: () => Get.back(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

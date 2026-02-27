import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.setUrl(
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.transparent, AppColors.accentRed.withAlpha(100)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// Title
              // RichText(
              //   text: const TextSpan(
              //     children: [
              //       TextSpan(
              //         text: "Drama Series | ",
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       TextSpan(
              //         text: "Listen Songs",
              //         style: TextStyle(color: Colors.red),
              //       ),
              //     ],
              //   ),
              // ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "HUSN",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "Anuv Jain",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.favorite_border, color: AppColors.white),
                        SizedBox(width: 10),
                        Icon(Icons.share, color: AppColors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// Album Image
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: mediaQuery.height * 0.55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://i.ytimg.com/vi/gJLVTKhTnog/maxresdefault.jpg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.error,
                    child: Icon(
                      Icons.play_arrow,
                      color: AppColors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Song Info
              const SizedBox(height: 10),

              /// Progress Bar
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ProgressBar(
                      progress: position,
                      total: total,
                      onSeek: (duration) {
                        _player.seek(duration);
                      },
                      baseBarColor: AppColors.grey,
                      progressBarColor: AppColors.error,
                      thumbColor: AppColors.error,
                      timeLabelTextStyle: text15(),
                    ),
                  );
                },
              ),

              /// Controls
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          color: AppColors.white,
                          size: 30,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                          color: AppColors.white,
                          size: 50,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            _player.pause();
                          } else {
                            _player.play();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          color: AppColors.white,
                          size: 30,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

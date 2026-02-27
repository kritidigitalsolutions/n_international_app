import 'package:flutter/material.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';

class SeriesPosterPlayerPage extends StatelessWidget {
  const SeriesPosterPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              /// Background Image
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  "assets/images/image1.png", // replace with your image
                  fit: BoxFit.cover,
                ),
              ),

              /// Top Text + Menu
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    /// Popup Menu
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.background,
                      ),
                      color: AppColors.background.withAlpha(200),
                      onSelected: (value) {
                        if (value == "quality") {
                          showOptionBottomSheet(context, "Select Quality", [
                            "144p",
                            "240p",
                            "360p",
                            "480p",
                            "720p HD",
                            "1080p Full HD",
                          ]);
                        } else if (value == "language") {
                          showOptionBottomSheet(context, "Select Language", [
                            "Hindi",
                            "Tamil",
                            "Telugu",
                            "Bhojpuri",
                            "Mandarin",
                          ]);
                        } else if (value == "share") {
                          print("Share clicked");
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "quality",
                          child: Text(
                            "Quality",
                            style: text13(color: AppColors.textPrimary),
                          ),
                        ),
                        PopupMenuItem(
                          value: "language",
                          child: Text(
                            "Language",
                            style: text13(color: AppColors.textPrimary),
                          ),
                        ),
                        PopupMenuItem(
                          value: "share",
                          child: Text(
                            "Share",
                            style: text13(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Bottom Controls
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background.withAlpha(175),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: AppColors.white.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.skip_previous,
                          color: AppColors.white,
                          size: 30,
                        ),
                        SizedBox(width: 20),
                        Icon(
                          Icons.pause_circle_filled,
                          color: AppColors.white,
                          size: 50,
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.skip_next, color: AppColors.white, size: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showOptionBottomSheet(
  BuildContext context,
  String title,
  List<String> options,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background.withAlpha(200),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: text18(
                color: AppColors.white,

                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...options.map(
              (e) => ListTile(
                title: Text(e, style: text15(color: AppColors.white)),
                trailing: const Icon(Icons.check, color: AppColors.error),
                onTap: () {
                  Navigator.pop(context);
                  print("$title selected: $e");
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

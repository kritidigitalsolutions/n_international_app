// listen_songs_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/song_controller/song_controllers.dart';

class ListenSongsPage extends StatelessWidget {
  const ListenSongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SongListController());

    return Scaffold(
      body: Stack(
        children: [
          backgroundGradient(),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Drama Series",
                          style: text14(color: AppColors.textPrimary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.back();
                            },
                        ),
                        TextSpan(
                          text: " | ",
                          style: text14(color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: "Listen Songs",
                          style: text14(color: AppColors.error),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print("Listen Songs tapped");
                              Get.toNamed(AppRoutes.songList);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center, // important
                    children: [
                      SizedBox(width: 10),
                      // Language Popup
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero, // remove internal padding
                        onSelected: (value) {
                          controller.selectedLanguage.value = value;
                          controller.getSongsByLanguage(value);
                          controller.toggle(0);
                        },
                        color: AppColors.card,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "Hindi",
                            child: Text("Hindi", style: text14()),
                          ),
                          PopupMenuItem(
                            value: "English",
                            child: Text("English", style: text14()),
                          ),
                          PopupMenuItem(
                            value: "Punjabi",
                            child: Text("Punjabi", style: text14()),
                          ),
                          PopupMenuItem(
                            value: "Tamil",
                            child: Text("Tamil", style: text14()),
                          ),
                          PopupMenuItem(
                            value: "Telugu",
                            child: Text("Telugu", style: text14()),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.selectedLanguage.value.isEmpty
                                  ? "Language"
                                  : controller.selectedLanguage.value,
                              style: text14(
                                color: controller.index.value == 0
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: controller.index.value == 0
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),
                      Text("|", style: text14(color: AppColors.white)),
                      const SizedBox(width: 8),

                      // My Playlist Button
                      CustomTextButton(
                        textColor: controller.index.value == 1
                            ? AppColors.error
                            : AppColors.white,
                        title: "My Playlist",
                        onPressed: () {
                          controller.toggle(1);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                /// Tabs (ONLY this needs Obx)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton('Popular', 0, controller),
                      _buildTabButton('Trending', 1, controller),
                      _buildTabButton('Top Charts', 2, controller),
                      _buildTabButton('New Releases', 3, controller),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                /// Song list (NO Obx needed)
                ///
                Obx(() {
                  if (controller.index.value == 0) {
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: controller.songs.length,
                        itemBuilder: (context, index) {
                          final song = controller.songs[index];
                          return ListTile(
                            onTap: () {
                              Get.toNamed(AppRoutes.musicPlay);
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song['imageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              song['title'],
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              song['artist'],
                              style: text12(color: AppColors.textSecondary),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () =>
                                  controller.showMoreOptions(index),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final song = controller.songs[index];
                        return ListTile(
                          onTap: () {
                            Get.toNamed(AppRoutes.musicPlay);
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              song['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            song['title'],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            song['artist'],
                            style: text12(color: AppColors.textSecondary),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => controller.showMoreOptions(index),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget songListCard(){
  //   return  Expanded(
  //                 child: ListView.builder(
  //                   padding: const EdgeInsets.all(8),
  //                   itemCount: controller.songs.length,
  //                   itemBuilder: (context, index) {
  //                     final song = controller.songs[index];
  //                     return ListTile(
  //                       leading: ClipRRect(
  //                         borderRadius: BorderRadius.circular(8),
  //                         child: Image.network(
  //                           song['imageUrl'],
  //                           width: 60,
  //                           height: 60,
  //                           fit: BoxFit.cover,
  //                         ),
  //                       ),
  //                       title: Text(
  //                         song['title'],
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                       subtitle: Text(
  //                         song['artist'],
  //                         style: TextStyle(color: Colors.grey[400]),
  //                       ),
  //                       trailing: IconButton(
  //                         icon: const Icon(
  //                           Icons.more_vert,
  //                           color: Colors.white70,
  //                         ),
  //                         onPressed: () => controller.showMoreOptions(index),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               );
  // }

  Widget _buildTabButton(
    String label,
    int index,
    SongListController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          margin: EdgeInsets.only(left: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.error : AppColors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: text14(
              color: isSelected ? AppColors.error : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ctr = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ctr.checkFirstTimeSnackbar();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 15, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextButton(
                  textColor: AppColors.error,

                  title: "Drama Series",
                  onPressed: () {},
                ),
                Text(
                  "|",
                  style: text16(
                    color: AppColors.textPrimary,
                  ).copyWith(height: 1.5),
                ),
                CustomTextButton(
                  textColor: AppColors.white,
                  title: "Listen Songs",
                  onPressed: () {
                    Get.toNamed(AppRoutes.songList);
                  },
                ),
              ],
            ),

            /// Search bar
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {},
              child: Container(
                height: 45, // give fixed height for proper centering
                padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: AbsorbPointer(
                  child: TextField(
                    style: text14(color: AppColors.textPrimary),
                    textAlignVertical: TextAlignVertical.center, // 👈 important
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search drama series",
                      hintStyle: text14(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.zero, // 👈 removes default offset
                      suffixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(ctr.tabs.length, (index) {
                  final isSelected = ctr.selectedTabIndex.value == index;

                  return InkWell(
                    onTap: () {
                      ctr.changeTab(index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        ctr.tabs[index],
                        style: text14(
                          color: isSelected
                              ? AppColors
                                    .error // selected color
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),

            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 16),

                  /// Main poster
                  SeriesCarousel(),

                  const SizedBox(height: 16),

                  Text(
                    "Series you may like",
                    style: text16(color: AppColors.textPrimary),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(ctr.seriesList.length, (index) {
                        final data = ctr.seriesList[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  data["image"] ?? '',
                                  height: 120,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 120,
                                      width: 100,
                                      color: AppColors.textSecondary,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['title'] ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "New Drama",
                    style: text16(color: AppColors.textPrimary),
                  ),

                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 200,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final data = ctr.seriesList[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                data["image"] ?? '',
                                height: 170,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.textSecondary,
                                    height: 170,
                                    width: double.infinity,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['title'] ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeriesCarousel extends StatelessWidget {
  final List<Map<String, String>> seriesList = [
    {
      "image": "assets/images/image2.png",
      "title": "Our Secret",
      "episodes": "10 episodes",
    },
    {
      "image": "assets/images/image2.png",
      "title": "Shadow & Bone",
      "episodes": "8 episodes",
    },
    {
      "image": "assets/images/image2.png",
      "title": "Peaky Blinders",
      "episodes": "12 episodes",
    },
  ];

  SeriesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.seriesDetails);
      },
      child: CarouselSlider.builder(
        itemCount: seriesList.length,
        options: CarouselOptions(
          height: 350,
          enlargeCenterPage: true, // ⭐ center card forward
          viewportFraction: 0.65,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          enableInfiniteScroll: true,
        ),
        itemBuilder: (context, index, realIndex) {
          final item = seriesList[index];

          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  item["image"]!,
                  width: 200,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 260,
                      color: AppColors.textSecondary,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item["title"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item["episodes"]!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }
}

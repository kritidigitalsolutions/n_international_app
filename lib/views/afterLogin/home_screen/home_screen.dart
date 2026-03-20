import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/home_controller.dart';

import '../../../data/api_responce_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ctr = Get.put(HomeController());

  @override
  void initState() {
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
                  style: text16(color: AppColors.textPrimary).copyWith(height: 1.5),
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
                height: 45,
                padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: AbsorbPointer(
                  child: TextField(
                    style: text14(color: AppColors.textPrimary),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search drama series",
                      hintStyle: text14(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: const Icon(
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        ctr.tabs[index],
                        style: text14(
                          color: isSelected ? AppColors.error : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),

            Expanded(
              child: Obx(() {
                if (ctr.seriesResponse.value.status == Status.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),

                    /// Main poster
                    const SeriesCarousel(),

                    const SizedBox(height: 16),

                    Text(
                "${ctr.tabs[ctr.selectedTabIndex.value]} Series",
                style: text16(color: AppColors.textPrimary),
                    ),

                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(ctr.currentSeriesList.length, (index) {
                          final data = ctr.currentSeriesList[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.seriesDetails, arguments: data);
                              },
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      data.posterImage ?? '',
                                      height: 120,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 120,
                                          width: 100,
                                          color: AppColors.textSecondary,
                                          child: const Icon(Icons.broken_image, color: Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      data.title ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
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
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 220,
                      ),
                      itemCount: ctr.newReleaseSeries.length,
                      itemBuilder: (context, index) {
                        final data = ctr.newReleaseSeries[index];
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.seriesDetails, arguments: data);
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  data.posterImage ?? '',
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.textSecondary,
                                      height: 170,
                                      width: double.infinity,
                                      child: const Icon(Icons.broken_image, color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.title ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class SeriesCarousel extends StatelessWidget {
  const SeriesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController ctr = Get.find<HomeController>();

    return Obx(() {
      final seriesList = ctr.currentSeriesList;

      if (seriesList.isEmpty) {
        if (ctr.seriesResponse.value.status == Status.loading) {
          return const SizedBox(height: 350, child: Center(child: CircularProgressIndicator()));
        }
        return const Center(
          child: Text("No series found", style: TextStyle(color: Colors.white)),
        );
      }

      return CarouselSlider.builder(
        itemCount: seriesList.length,
        options: CarouselOptions(
          height: 350,
          enlargeCenterPage: true,
          viewportFraction: 0.65,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          enableInfiniteScroll: seriesList.length > 1,
        ),
        itemBuilder: (context, index, realIndex) {
          final item = seriesList[index];

          return GestureDetector(
            onTap: () {
              Get.toNamed(
                AppRoutes.seriesDetails,
                arguments: item,
              );
            },
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item.posterImage ?? '',
                    width: 200,
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 260,
                        color: AppColors.textSecondary,
                        child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.totalEpisodes ?? 0} episodes",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

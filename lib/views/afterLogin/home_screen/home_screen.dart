import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:n_square_international/data/api_responce_data.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/routes/app_routes.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/home_controller.dart';
import 'package:n_square_international/viewModel/afterLogin/notification_controller.dart';

import '../../../res/app_url.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ctr = Get.put(HomeController());
  final notificationCtr = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    ctr.checkFirstTimeSnackbar();
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes}m ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours}h ago";
      } else {
        return DateFormat('dd MMM').format(date);
      }
    } catch (e) {
      return "";
    }
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Remove this?", style: text18(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("This notification will be permanently removed.", style: text14(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: text14(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              notificationCtr.deleteNotification(id);
              Navigator.pop(context);
            },
            child: Text("Delete", style: text14(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFullNotification(BuildContext context, String title, String message, String time) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 24),
                  ),
                  Text(time, style: text12(color: Colors.white38)),
                ],
              ),
              const SizedBox(height: 20),
              Text(title, style: text20(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              Text(message, style: text15(color: Colors.white70,)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close", style: text14(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSidePopup(BuildContext context) {
    notificationCtr.fetchNotifications();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Notifications",
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Text("Notifications", style: text24(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      if (notificationCtr.isLoading.value) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      if (notificationCtr.notifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
                              const SizedBox(height: 16),
                              Text("No notifications yet", style: text16(color: Colors.white38)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notificationCtr.notifications.length,
                        itemBuilder: (context, index) {
                          final item = notificationCtr.notifications[index];
                          final isUnread = !(item.isRead ?? false);
                          final time = _formatTime(item.createdAt);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isUnread ? Colors.white.withOpacity(0.04) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isUnread ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                notificationCtr.markAsRead(item.sId ?? "");
                                _showFullNotification(context, item.title ?? "Notification", item.message ?? "", time);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isUnread ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        isUnread ? Icons.notifications_active : Icons.notifications_none,
                                        color: isUnread ? AppColors.primary : Colors.white24,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title ?? "Update",
                                                  style: text15(
                                                    color: isUnread ? Colors.white : Colors.white60,
                                                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(time, style: text11(color: Colors.white24)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.message ?? "",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: text13(color: Colors.white38, ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _showDeleteConfirmation(context, item.sId ?? ""),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.15), size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => notificationCtr.markAllAsRead(),
                              child: Text("Mark all read", style: text14(color: Colors.white38)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text("Got it", style: text14(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
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
              children: [
                const Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextButton(textColor: AppColors.error, title: "Drama Series", onPressed: () {}),
                    Text("|", style: text16(color: AppColors.textPrimary).copyWith(height: 1.5)),
                    CustomTextButton(
                      textColor: AppColors.white,
                      title: "Listen Songs",
                      onPressed: () => Get.toNamed(AppRoutes.songList),
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
                Obx(() => Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        notificationCtr.unreadCount.value > 0 ? Icons.notifications_active : Icons.notifications_none,
                        color: notificationCtr.unreadCount.value > 0 ? AppColors.primary : Colors.white,
                        size: 28,
                      ),
                      onPressed: () => _showNotificationSidePopup(context),
                    ),
                    if (notificationCtr.unreadCount.value > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '${notificationCtr.unreadCount.value}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                )),
              ],
            ),
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: AppColors.white.withAlpha(50), borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: ctr.searchController,
                onChanged: (value) => ctr.searchSeries(value),
                cursorColor: AppColors.error,
                style: text14(color: AppColors.textPrimary),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search drama series",
                  hintStyle: text14(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: Obx(() => ctr.isSearching.value
                    ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20), onPressed: () => ctr.clearSearch())
                    : const Icon(Icons.search, color: AppColors.textSecondary, size: 20)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (ctr.isSearching.value) return const SizedBox.shrink();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(ctr.tabs.length, (index) {
                  final isSelected = ctr.selectedTabIndex.value == index;
                  return InkWell(
                    onTap: () => ctr.changeTab(index),
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
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (ctr.isSearching.value) {
                  if (ctr.searchResults.isEmpty) {
                    return Center(child: Text("No results found for '${ctr.searchController.text}'", style: text14(color: AppColors.textSecondary)));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 220),
                    itemCount: ctr.searchResults.length,
                    itemBuilder: (context, index) {
                      final data = ctr.searchResults[index];
                      return GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.seriesDetails, arguments: data),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                AppUrls.getImageUrl(data.posterImage),
                                height: 170,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.textSecondary, height: 170, width: double.infinity, child: const Icon(Icons.broken_image, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(data.title ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  );
                }
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),
                    const SeriesCarousel(),
                    const SizedBox(height: 16),
                    Text("${ctr.tabs[ctr.selectedTabIndex.value]} Series", style: text16(color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(ctr.currentSeriesList.length, (index) {
                          final data = ctr.currentSeriesList[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.seriesDetails, arguments: data),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      AppUrls.getImageUrl(data.posterImage),
                                      height: 120,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(height: 120, width: 100, color: AppColors.textSecondary, child: const Icon(Icons.broken_image, color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(width: 100, child: Text(data.title ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("New Drama", style: text16(color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 220),
                      itemCount: ctr.newReleaseSeries.length,
                      itemBuilder: (context, index) {
                        final data = ctr.newReleaseSeries[index];
                        return GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.seriesDetails, arguments: data),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  AppUrls.getImageUrl(data.posterImage),
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: AppColors.textSecondary, height: 170, width: double.infinity, child: const Icon(Icons.broken_image, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(data.title ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
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
        if (ctr.seriesResponse.value.status == Status.loading) return const SizedBox(height: 350, child: Center(child: CircularProgressIndicator(color: AppColors.primary, backgroundColor: Colors.white24,)));
        return const Center(child: Text("No series found", style: TextStyle(color: Colors.white)));
      }
      return CarouselSlider.builder(
        itemCount: seriesList.length,
        options: CarouselOptions(height: 350, enlargeCenterPage: true, viewportFraction: 0.65, enlargeStrategy: CenterPageEnlargeStrategy.zoom, enableInfiniteScroll: seriesList.length > 1),
        itemBuilder: (context, index, realIndex) {
          final item = seriesList[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.seriesDetails, arguments: item),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    AppUrls.getImageUrl(item.posterImage),
                    width: 200,
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(width: 200, height: 260, color: AppColors.textSecondary, child: const Icon(Icons.broken_image, color: Colors.white, size: 40)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(item.title ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("${item.totalEpisodes ?? 0} episodes", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          );
        },
      );
    });
  }
}

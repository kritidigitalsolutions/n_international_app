import 'package:get/get.dart';
import 'package:n_square_international/main.dart';
import 'package:n_square_international/views/afterLogin/SeriesDetail/series_details.dart';
import 'package:n_square_international/views/afterLogin/SeriesDetail/video_play_page.dart';
import 'package:n_square_international/views/afterLogin/song/musicplay_page.dart';
import 'package:n_square_international/views/afterLogin/song/song_list_page.dart';
import 'package:n_square_international/views/afterLogin/profile/about_us_page.dart';
import 'package:n_square_international/views/afterLogin/profile/history_page.dart';
import 'package:n_square_international/views/afterLogin/profile/language_page.dart';
import 'package:n_square_international/views/afterLogin/profile/offline_download.dart';
import 'package:n_square_international/views/afterLogin/profile/recharge_page.dart';
import 'package:n_square_international/views/afterLogin/profile/setting_page.dart';
import 'package:n_square_international/views/beforeLogin/login_screen.dart';
import 'package:n_square_international/views/beforeLogin/otp_page.dart';
import 'package:n_square_international/views/beforeLogin/welcome_screen.dart';
import 'package:n_square_international/views/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),

    GetPage(
      name: AppRoutes.welcomePage,
      page: () => WelcomeScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.otp,
      page: () => OtpScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.myHome,
      page: () => MyHomePage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.recharge,
      page: () => const RechargeScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.language,
      page: () => SelectLanguageScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.offlineDownload,
      page: () => const OfflineDownloadedScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.setting,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.aboutus,
      page: () => const AboutUsScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.seriesDetails,
      page: () => const SeriesDetailPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.songList,
      page: () => const ListenSongsPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.musicPlay,
      page: () => const MusicPlayerPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.videoPlay,
      page: () => const SeriesPosterPlayerPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

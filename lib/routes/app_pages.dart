import 'package:get/get.dart';
import 'package:n_square_international/main.dart';
import 'package:n_square_international/views/afterLogin/SeriesDetail/series_details.dart';
import 'package:n_square_international/views/afterLogin/SeriesDetail/video_play_page.dart';
import 'package:n_square_international/views/afterLogin/song/musicplay_page.dart';
import 'package:n_square_international/views/afterLogin/song/song_list_page.dart';
import 'package:n_square_international/views/afterLogin/profile/about_us_page.dart';
import 'package:n_square_international/views/afterLogin/profile/contact_us_page.dart';
import 'package:n_square_international/views/afterLogin/profile/history_page.dart';
import 'package:n_square_international/views/afterLogin/profile/language_page.dart';
import 'package:n_square_international/views/afterLogin/profile/offline_download.dart';
import 'package:n_square_international/views/afterLogin/profile/privacy_policy_page.dart';
import 'package:n_square_international/views/afterLogin/profile/recharge_page.dart';
import 'package:n_square_international/views/afterLogin/profile/setting_page.dart';
import 'package:n_square_international/views/afterLogin/profile/terms_conditions_page.dart';
import 'package:n_square_international/views/beforeLogin/enter_full_name_page.dart';
import 'package:n_square_international/views/beforeLogin/login_screen.dart';
import 'package:n_square_international/views/beforeLogin/otp_page.dart';
import 'package:n_square_international/views/beforeLogin/welcome_screen.dart';
import 'package:n_square_international/views/splash_screen.dart';
import '../views/afterLogin/profile/company_info_page.dart';
import '../views/afterLogin/profile/edit_profile_page.dart';
import '../views/afterLogin/profile/full_profile_page.dart';
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
      page: () => RechargeScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.history,
      page: () => HistoryScreen(),
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

    GetPage(
      name: AppRoutes.fullName,
      page: () => const EnterFullNamePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.fullProfile,
      page: () => const FullProfilePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfilePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.aboutCompany,
      page: () => const CompanyInfoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const ContactUsPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

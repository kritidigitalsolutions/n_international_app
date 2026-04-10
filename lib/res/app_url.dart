class AppUrls {

  // static const String baseUrl = "http://192.168.1.40:9000/api";
  // static const String baseImageUrl = "http://192.168.1.40:9000";
  static const String baseUrl = "https://n-square-international.vercel.app/api";
  static const String baseImageUrl = "https://n-square-international.vercel.app";

  //--------------------------------------------------
  //auth
  //----------------------------------------------------

  static const String sentOtp = "$baseUrl/auth/send-otp";
  static const String otpVerify = "$baseUrl/auth/verify-otp";
  static const String register = "$baseUrl/user/profile-info";
  //--------------------------------------------------
  //profile
  //----------------------------------------------------
  static const String userprofile = "$baseUrl/user/";
  static const String editprofile = "$baseUrl/user/profile-edit";

  //-----------------------------------------------------------
  // content
  //-----------------------------------------------

  static const String aboutUs = "$baseUrl/content/about";
  static const String contactUs = "$baseUrl/content/contact";
  static const String privacypolicy = "$baseUrl/content/legal/privacy";
  static const String termsandcondition = "$baseUrl/content/legal/terms";

  //-----------------------------------------------------------
  // OTT / Series
  //-----------------------------------------------
  static const String seriesList = "$baseUrl/ott/series";
  static String episodesList(String seriesId) => "$seriesList/$seriesId/episodes";
  static String playEpisode(String episodeId) => "$baseUrl/ott/episodes/$episodeId/play";
  static String unlockEpisode(String episodeId) => "$baseUrl/ott/episodes/$episodeId/unlock";

  // Episode Like
  static String likeEpisode(String episodeId) => "$baseUrl/ott/episodes/$episodeId/like";
  static String likeStatus(String episodeId) => "$baseUrl/ott/episodes/$episodeId/like-status";

  //-----------------------------------------------------------
  // Favorites
  //-----------------------------------------------
  static const String favoriteList = "$baseUrl/ott/favorites";
  static String deleteFavorite(String seriesId) => "$favoriteList/$seriesId";
  static String addFavorite(String seriesId) => "$favoriteList/$seriesId";

  //-----------------------------------------------------------
  // Audio / Songs
  //-----------------------------------------------
  static const String audioSongs = "$baseUrl/audio/songs";
  static const String audioPlaylist = "$baseUrl/audio/playlist";
  static String togglePlaylist(String songId) => "$audioPlaylist/$songId";
  static String playSong(String songId) => "$audioSongs/$songId/play";
  //-----------------------------------------------------------
  //Songs Favorites
  //-----------------------------------------------
  static const String favoriteSong = "$baseUrl/audio/favorites";
  static String deleteFavoriteSong(String songid) => "$favoriteSong/$songid";
  static String addFavoriteSong(String songid) => "$favoriteSong/$songid";
  //-----------------------------------------------------------
  // offline downloads
  //-----------------------------------------------
  static const String addDownload = "$baseUrl/library/offline-downloads";
  static String deleteDownload(String downloadId) => "$baseUrl/library/offline-downloads/$downloadId";
  static const String getdownload = "$baseUrl/library/offline-downloads";
  // -----------------------------------------------------------
  // watch histroy
  //-----------------------------------------------
  static const String addHistory = "$baseUrl/library/history";
  static const String getHistory = "$baseUrl/library/history";
  static String deleteHistory(String historyId) => "$baseUrl/library/history/$historyId";

  //-----------------------------------------------------------
  // Wallet
  //-----------------------------------------------
  static const String addMoneyOrder = "$baseUrl/wallet/add-money/order";
  static const String verifyPayment = "$baseUrl/wallet/add-money/verify";

  //-----------------------------------------------------------
  // Notifications
  //-----------------------------------------------
  static const String notification = "$baseUrl/notifications";
  static String readNotification(String notificationId) => "$baseUrl/notifications/$notificationId/read";
  static const String readallnotification = "$baseUrl/notifications/read-all";
  static const String updateFcmToken = "$baseUrl/notifications/fcm-token";

  //-----------------------------------------------------------
  // images
  //-----------------------------------------------
  static String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return "$baseImageUrl$url";
  }
}

class AppUrls {
  static const String baseUrl = "http://192.168.1.12:9000/api";
  static const String baseImageUrl = "http://192.168.1.12:9000";

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

  //-----------------------------------------------------------
  // Favorites
  //-----------------------------------------------
  static const String favoriteList = "$baseUrl/ott/favorites";
  static String deleteFavorite(String seriesId) => "$favoriteList/$seriesId";
  static String addFavorite(String seriesId) => "$favoriteList/$seriesId";

  //-----------------------------------------------------------
  // images
  //-----------------------------------------------
  static String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return "$baseImageUrl$url";
  }
}

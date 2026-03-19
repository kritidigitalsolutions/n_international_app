class AppUrls {
  static const String baseUrl = "http://192.168.1.12:9000/api";

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
  }

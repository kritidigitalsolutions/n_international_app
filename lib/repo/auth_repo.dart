import 'package:dio/dio.dart';

import '../data/network/api_network_service.dart';
import '../model/request/auth_request_model/auth_req_model.dart';
import '../model/responce/auth_responce_model/auth_res_model.dart';
import '../res/app_url.dart';

class AuthRepo {
  final _api = NetworkApiService();

  // send otp
  Future<void> sendOtp(String phone) async {
    try {
      await _api.postApi(AppUrls.sentOtp, {"phone": phone});
    } catch (e) {
      rethrow;
    }
  }

  /// verify otp

  Future<Map<String, dynamic>> verfiyOtp(String phone, String otp) async {
    try {
      final res = await _api.postApi(AppUrls.otpVerify, {
        "otp": otp,
        "phone": phone,
      });
      return res;
    } catch (e) {
      rethrow;
    }
  }
/// register
  Future<UserDetailsResModel> registerUser(UserDetailsReqModel model) async {
    try {
      print("📤 REGISTER API CALLED");
      print("REGISTER DATA => ${model.toJson()}");

      final dio = Dio();

      final response = await dio.post(
        AppUrls.register,
        data: model.toJson(),
      );

      print("✅ REGISTER RESPONSE => ${response.data}");

      return UserDetailsResModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        print("❌ STATUS CODE => ${e.response?.statusCode}");
        print("❌ SERVER RESPONSE => ${e.response?.data}");
      } else {
        print("❌ REGISTER ERROR => $e");
      }
      rethrow;
    }
  }
}
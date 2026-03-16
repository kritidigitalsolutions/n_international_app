import 'package:dio/dio.dart';

import '../model/request/auth_request_model/auth_req_model.dart';
import '../res/app_url.dart';

class UserRepo {
  final Dio _dio = Dio();

  Future<User> getUser(String token) async {
    try {
      final response = await _dio.get(
        AppUrls.userprofile,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final userJson = response.data["user"];
        return User.fromJson(userJson);
      } else {
        throw Exception("Failed to fetch user data");
      }
    } catch (e) {
      print("GET USER ERROR: $e");
      rethrow;
    }
  }
}

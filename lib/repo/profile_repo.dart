import 'package:dio/dio.dart';

import '../model/request/auth_request_model/auth_req_model.dart';
import '../res/app_url.dart';
import '../utils/hive_service/hive_service.dart';
import '../utils/hive_service/userdetail.dart';

class ProfileRepo {
  Future<UserDetails> editProfile(UserDetailsReqModel model) async {
    try {
      final dio = Dio();
      final token = HiveService.getToken();

      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      };

      final Map<String, dynamic> dataMap = {
        "name": model.name,
        "phone": model.phone,
        "email": model.email,
      };

      final formData = FormData.fromMap(dataMap);

      final response = await dio.patch(AppUrls.editprofile, data: formData);

      if (response.data["success"] == true || response.statusCode == 200) {
        final userJson = response.data["user"];
        final oldUser = HiveService.getUser();

        final updatedUser = UserDetails(
          name: userJson["name"] ?? model.name,
          phone: userJson["phone"] ?? model.phone,
          email: userJson["email"] ?? model.email,

          // 🔥 IMAGE NEVER TOUCH
          image: oldUser?.image,

          token: oldUser?.token ?? "",
        );

        return updatedUser;
      } else {
        throw Exception(response.data["message"] ?? "Failed to update profile");
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data["message"] ?? "Server Error");
      }
      rethrow;
    }
  }
}
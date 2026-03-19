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

      // Ensure field names match what your backend expects
      // Based on common practices, "email" should be "email"
      final Map<String, dynamic> dataMap = {
        "name": model.name,
        "phone": model.phone,
        "email": model.email, // This is the field that wasn't updating
      };

      if (model.image != null && model.image.isNotEmpty && !model.image.startsWith('http')) {
        dataMap["profileImage"] = await MultipartFile.fromFile(
          model.image,
          filename: model.image.split('/').last,
        );
      }

      final formData = FormData.fromMap(dataMap);

      print("🚀 PATCH Request to: ${AppUrls.editprofile}");
      print("🚀 DATA: $dataMap");

      final response = await dio.patch(AppUrls.editprofile, data: formData);

      print("✅ API RESPONSE: ${response.data}");

      if (response.data["success"] == true || response.statusCode == 200) {
        final userJson = response.data["user"];
        final oldUser = HiveService.getUser();

        final updatedUser = UserDetails(
          name: userJson["name"] ?? model.name,
          phone: userJson["phone"] ?? model.phone,
          email: userJson["email"] ?? model.email, // This ensures Hive gets the new email
          image: userJson["profileImage"] ?? oldUser?.image,
          token: oldUser?.token ?? "",
        );

        return updatedUser;
      } else {
        throw Exception(response.data["message"] ?? "Failed to update profile");
      }
    } catch (e) {
      if (e is DioException) {
        print("❌ DIO ERROR: ${e.response?.data}");
        throw Exception(e.response?.data["message"] ?? "Server Error");
      }
      rethrow;
    }
  }
}

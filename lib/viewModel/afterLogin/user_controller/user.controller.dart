import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:n_square_international/res/app_url.dart';
import '../../../utils/hive_service/hive_service.dart';

class UserController extends GetxController {
  var userName = "".obs; // reactive variable
  final Dio _dio = Dio();

  // Fetch user name using token from Hive
  Future<void> fetchUserName() async {
    try {
      final token = HiveService.getToken();
      if (token == null || token.isEmpty) {
        print("No token found in Hive");
        return;
      }
      print("Token used for API: $token");

      final response = await _dio.get(AppUrls.userprofile,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        final name = response.data["user"]["name"] ?? "";
        userName.value = name;
      } else {
        print("Failed to fetch user: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }
}
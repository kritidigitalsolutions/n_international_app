import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/routes/app_routes.dart';
import '../../../utils/hive_service/hive_service.dart';

class UserController extends GetxController {
  var userName = "".obs; // reactive variable
  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  void loadInitialData() {
    final user = HiveService.getUser();
    if (user != null && user.name != null && user.name!.isNotEmpty) {
      userName.value = user.name!;
    }
  }

  // Fetch user name using token from Hive
  Future<void> fetchUserName() async {
    try {
      final token = HiveService.getToken();
      if (token == null || token.isEmpty) {
        print("No token found in Hive");
        return;
      }

      final response = await _dio.get(AppUrls.userprofile,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        final name = response.data["user"]["name"] ?? "";
        if (name.isNotEmpty) {
          userName.value = name;
          // Sync back to Hive if API gives a better name
          final user = HiveService.getUser();
          if (user != null) {
            user.name = name;
            await HiveService.saveUser(user);
          }
        }
      } else {
        print("Failed to fetch user: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  /// logout user
  void logout() async {
    await HiveService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}

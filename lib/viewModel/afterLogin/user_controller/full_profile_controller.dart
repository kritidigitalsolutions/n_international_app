import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/utils/hive_service/hive_service.dart';

class FullProfileController extends GetxController {
  var name = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var image = "".obs;
  var walletBalance = 0.obs;
  var starPoints = 0.obs;
  var isLoading = false.obs;

  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final token = HiveService.getToken();
      if (token == null) return;

      final response = await _dio.get(
        AppUrls.userprofile,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        final user = response.data["user"];
        name.value = user["name"] ?? "";
        phone.value = user["phone"] ?? "";
        email.value = user["email"] ?? "";
        image.value = user["profileImage"] ?? "";
        
        // Handle balance safely as num then convert to int
        var balance = user["walletBalance"] ?? 0;
        walletBalance.value = num.parse(balance.toString()).toInt();
        starPoints.value = walletBalance.value;
      }
    } catch (e) {
      print("Profile API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

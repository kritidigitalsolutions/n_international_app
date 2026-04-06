import 'package:dio/dio.dart';
import 'package:n_square_international/res/app_url.dart';
import 'package:n_square_international/utils/hive_service/hive_service.dart';

class WalletRepo {
  final Dio _dio = Dio();

  Future<dynamic> createOrder(Map<String, dynamic> data) async {
    try {
      final token = HiveService.getToken();
      final response = await _dio.post(
        AppUrls.addMoneyOrder,
        data: data,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data["message"] ?? "Failed to create order");
      }
      rethrow;
    }
  }

  Future<dynamic> verifyPayment(Map<String, dynamic> data) async {
    try {
      final token = HiveService.getToken();
      final response = await _dio.post(
        AppUrls.verifyPayment,
        data: data,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data["message"] ?? "Payment verification failed");
      }
      rethrow;
    }
  }
}

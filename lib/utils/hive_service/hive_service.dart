import 'package:hive/hive.dart';
import 'package:n_square_international/utils/hive_service/userdetail.dart';

class HiveService {

  static final Box<UserDetails> _box = Hive.box<UserDetails>('userBox');

  static Future<void> saveUser(UserDetails user) async {
    await _box.put('user', user);
  }

  static UserDetails? getUser() {
    return _box.get('user');
  }

  static String? getToken() {
    return _box.get('user')?.token;
  }

  static Future<void> logout() async {
    await _box.clear();
  }

  static bool isLogin() {
    return _box.containsKey('user');
  }

  /// Save user from API response
  static Future<void> saveUserFromApi(Map<String, dynamic> user) async {

    final oldUser = getUser();

    final userDetails = UserDetails(
      name: user["name"] ?? "",
      email: user["email"] ?? "",
      phone: user["phone"] ?? "",
      image: user["image"] ?? "",
      token: oldUser?.token ?? "",
    );

    await saveUser(userDetails);
  }
}

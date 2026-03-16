

import 'package:hive/hive.dart';
import 'package:n_square_international/utils/hive_service/userdetail.dart';

class HiveService {
  static final Box<UserDetails> _box = Hive.box<UserDetails>('userBox');

  static Future<void> saveUser(UserDetails user) async {
    await _box.put('user', user);
    print("User saved in hive: ${_box.get('user')}");
  }

  static UserDetails? getUser() {
    return _box.get('user');
  }

  static String? getToken() {
    return _box.get('user')?.token; // ✅ FIX HERE
  }

  static Future<void> logout() async {
    await _box.clear();
  }

  static bool isLogin() {
    return _box.containsKey('user');
  }
}

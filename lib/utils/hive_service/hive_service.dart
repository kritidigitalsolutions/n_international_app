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

  static Future<void> saveUserFromApi(Map<String, dynamic> user) async {
    final oldUser = getUser();

    final userDetails = UserDetails(
      name: user["name"] ?? "",
      email: user["email"] ?? "",
      phone: user["phone"] ?? "",

      // 👇 IMPORTANT FIX
      image: (oldUser?.image != null && oldUser!.image!.startsWith('/'))
          ? oldUser.image   // local image preserve
          : user["image"] ?? "",

      token: oldUser?.token ?? "",
    );

    await saveUser(userDetails);
  }
}


// import 'package:hive/hive.dart';
// import 'package:n_square_international/utils/hive_service/userdetail.dart';
//
// class HiveService {
//   // Use a getter instead of a static final to avoid "Box not found" error during initialization
//   static Box<UserDetails> get _box {
//     if (!Hive.isBoxOpen('userBox')) {
//       throw HiveError('userBox is not open. Ensure Hive.openBox("userBox") is awaited in main().');
//     }
//     return Hive.box<UserDetails>('userBox');
//   }
//
//   static Future<void> saveUser(UserDetails user) async {
//     await _box.put('user', user);
//   }
//
//   static UserDetails? getUser() {
//     try {
//       return _box.get('user');
//     } catch (e) {
//       return null;
//     }
//   }
//
//   static String? getToken() {
//     try {
//       return _box.get('user')?.token;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   static Future<void> logout() async {
//     await _box.clear();
//   }
//
//   static bool isLogin() {
//     try {
//       return _box.containsKey('user');
//     } catch (e) {
//       return false;
//     }
//   }
//
//   static Future<void> saveUserFromApi(Map<String, dynamic> user) async {
//     final oldUser = getUser();
//
//     final userDetails = UserDetails(
//       name: user["name"] ?? "",
//       email: user["email"] ?? "",
//       phone: user["phone"] ?? "",
//       image: (oldUser?.image != null && oldUser!.image!.startsWith('/'))
//           ? oldUser.image
//           : user["image"] ?? "",
//       token: oldUser?.token ?? "",
//     );
//
//     await saveUser(userDetails);
//   }
// }

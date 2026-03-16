// -------------------------------------------------
// user details
//------------------------------------------------------

class UserDetailsResModel {
  UserDetailsResModel({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  final bool? success;
  final String? message;
  final String? token;
  final User? user;

  factory UserDetailsResModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsResModel(
      success: json["success"],
      message: json["message"],
      token: json["token"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }
}

class User {
  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.dob,
    required this.gender,
  });

  final String? id;
  final String? name;
  final String? phone;

  final String? dob;
  final String? gender;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      name: json["name"],
      phone: json["phone"],
      dob: json["dob"],
      gender: json["gender"],
    );
  }
}

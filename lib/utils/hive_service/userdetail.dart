import 'package:hive/hive.dart';

// part 'userdetail.g.dart';

@HiveType(typeId: 0)
class UserDetails extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? image;

  @HiveField(3)
  String token;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  int? createdAt; // Store creation timestamp

  UserDetails({
    required this.name,
    required this.email,
    this.image,
    required this.token,
    this.phone,
    this.createdAt,
  });
}

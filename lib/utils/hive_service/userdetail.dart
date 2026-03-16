
import 'package:hive/hive.dart';

part 'userdetail.g.dart';

@HiveType(typeId: 0)
class UserDetails extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String dob;

  @HiveField(2)
  String gender;

  @HiveField(3)
  String? image;

  @HiveField(4)
  String token;

  @HiveField(5)
  String? phone;

  UserDetails({
    required this.name,
    required this.dob,
    required this.gender,
    this.image,
    required this.token,
    required this.phone,
  });
}

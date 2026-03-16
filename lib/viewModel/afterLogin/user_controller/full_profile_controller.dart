import 'package:get/get.dart';
import 'package:n_square_international/utils/hive_service/hive_service.dart';
import 'package:n_square_international/utils/hive_service/userdetail.dart';

class FullProfileController extends GetxController {
  var name = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var dob = "".obs;
  var gender = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() {
    final user = HiveService.getUser();
    if (user != null) {
      name.value = user.name ?? "";
      phone.value = user.phone ?? "";
      email.value = user.token ?? "";
      dob.value = user.dob ?? "";
      gender.value = user.gender ?? "";
    }
  }
}

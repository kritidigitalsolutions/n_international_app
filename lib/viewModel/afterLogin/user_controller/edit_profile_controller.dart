import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../model/request/auth_request_model/auth_req_model.dart';
import '../../../repo/profile_repo.dart';
import '../../../utils/hive_service/hive_service.dart';
import 'full_profile_controller.dart';

class EditProfileController extends GetxController {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  Rx<File?> profileImage = Rx<File?>(null);

  final ImagePicker picker = ImagePicker();
  final _repo = ProfileRepo();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserFromHive();
  }

  void loadUserFromHive() {

    final user = HiveService.getUser();

    if (user != null) {

      nameController.text = user.name;
      emailController.text = user.email;
      mobileController.text = user.phone ?? "";

      if (user.image != null && user.image!.isNotEmpty) {
        // Only set profileImage if it's a local file path or handle URL appropriately
        // For now, keeping your logic but being mindful that user.image might be a URL
        if (!user.image!.startsWith('http')) {
           profileImage.value = File(user.image!);
        }
      }
    }
  }

  Future<void> pickImageWithPermission(ImageSource source) async {

    Permission permission =
    source == ImageSource.camera ? Permission.camera : Permission.photos;

    PermissionStatus status = await permission.request();

    if (status.isGranted) {

      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        profileImage.value = File(image.path);
      }

    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> editProfile() async {

    try {

      isLoading.value = true;

      final model = UserDetailsReqModel(
        name: nameController.text.trim(),
        phone: mobileController.text.trim(),
        email: emailController.text.trim(),
        image: profileImage.value?.path ?? "",
      );

      final response = await _repo.editProfile(model);

      /// Save updated user
      await HiveService.saveUser(response);

      // Refresh FullProfileController if it's in memory
      if (Get.isRegistered<FullProfileController>()) {
        Get.find<FullProfileController>().fetchUserProfile();
      }

      CustomSnackbar.showSuccess(
        title: "Success",
        message: "Profile updated successfully",
      );

      Get.back();

    } catch (e) {

      print(e);

      CustomSnackbar.showSuccess(
        title: "error",
        message: "Profile not updated",
      );

    } finally {

      isLoading.value = false;

    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.onClose();
  }
}

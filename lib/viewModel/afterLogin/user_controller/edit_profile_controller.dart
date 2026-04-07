import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:n_square_international/viewModel/afterLogin/user_controller/user.controller.dart';

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
    print("EDIT PROFILE CALLED");
    try {
      isLoading.value = true;

      final model = UserDetailsReqModel(
        name: nameController.text.trim(),
        phone: mobileController.text.trim(),
        email: emailController.text.trim(),
        image: "",
      );

      // 👉 API call only for text data
      await _repo.editProfile(model);

      final oldUser = HiveService.getUser();

      if (oldUser != null) {
        oldUser.name = nameController.text.trim();
        oldUser.email = emailController.text.trim();
        oldUser.phone = mobileController.text.trim();

        if (profileImage.value != null) {
          oldUser.image = profileImage.value!.path;
        }

        await HiveService.saveUser(oldUser);
      }

      // Update other controllers immediately
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().userName.value = nameController.text.trim();
      }
      if (Get.isRegistered<FullProfileController>()) {
        Get.find<FullProfileController>().fetchUserProfile();
      }

      FocusManager.instance.primaryFocus?.unfocus();

      Get.back();

      CustomSnackbar.showSuccess(
        title: "Success",
        message: "Profile updated successfully",
      );

    } catch (e) {
      print("CATCH ERROR: $e");

      final oldUser = HiveService.getUser();

      if (oldUser != null) {
        oldUser.name = nameController.text.trim();
        oldUser.email = emailController.text.trim();

        if (profileImage.value != null) {
          oldUser.image = profileImage.value!.path;
        }

        await HiveService.saveUser(oldUser);
      }

      // Update other controllers even if API fails (saved locally)
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().userName.value = nameController.text.trim();
      }

      Get.back();

      CustomSnackbar.showSuccess(
        title: "Saved Locally",
        message: "Profile saved without server",
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

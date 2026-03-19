
import 'package:get/get.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';

import '../../../data/api_responce_data.dart';
import '../../../model/responce/policy_res_model/about_res_model.dart';
import '../../../model/responce/policy_res_model/contact_us_res_model.dart';
import '../../../model/responce/policy_res_model/policy_res_model.dart';
import '../../../repo/policy_repo.dart';

class PolicyControllers extends GetxController {
  final PolicyRepo _repo = PolicyRepo();

  var privacyPolicy = ApiResponse<PolicyResModel>.loading().obs;
  var termsConditions = ApiResponse<PolicyResModel>.loading().obs;
  var aboutUs = ApiResponse<AboutUsResModel>.loading().obs;
  var contactUs = ApiResponse<ContactUsResModel>.loading().obs;

  Future<void> fetchPrivacyPolicy() async {
    privacyPolicy.value = ApiResponse.loading();
    try {
      final res = await _repo.getPrivacyPolicy();
      privacyPolicy.value = ApiResponse.completed(res);
    } catch (e) {
      privacyPolicy.value = ApiResponse.error("Failed to load privacy policy");
      CustomSnackbar.showError(title: 'Error', message: 'Failed to load privacy policy');
    }
  }

  Future<void> fetchTermsConditions() async {
    termsConditions.value = ApiResponse.loading();
    try {
      final res = await _repo.getTermsConditions();
      termsConditions.value = ApiResponse.completed(res);
    } catch (e) {
      termsConditions.value = ApiResponse.error("Failed to load terms and conditions");
      CustomSnackbar.showError(title: 'Error', message: 'Failed to load terms and conditions');
    }
  }

  Future<void> fetchAboutUs() async {
    aboutUs.value = ApiResponse.loading();
    try {
      final res = await _repo.getAboutUs();
      aboutUs.value = ApiResponse.completed(res);
    } catch (e) {
      aboutUs.value = ApiResponse.error("Failed to load about us data");
      CustomSnackbar.showError(title: 'Error', message: 'Failed to load about us data');
    }
  }

  Future<void> fetchContactUs() async {
    contactUs.value = ApiResponse.loading();
    try {
      final res = await _repo.getContactUs();
      contactUs.value = ApiResponse.completed(res);
    } catch (e) {
      contactUs.value = ApiResponse.error("Failed to load contact us data");
      CustomSnackbar.showError(title: 'Error', message: 'Failed to load contact us data');
    }
  }
}

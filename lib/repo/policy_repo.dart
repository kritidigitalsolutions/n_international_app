import '../data/network/api_network_service.dart';
import '../model/responce/policy_res_model/about_res_model.dart';
import '../model/responce/policy_res_model/contact_us_res_model.dart';
import '../model/responce/policy_res_model/policy_res_model.dart';
import '../res/app_url.dart';

class PolicyRepo {
  final _api = NetworkApiService();

  Future<AboutUsResModel> getAboutUs() async {
    try {
      final res = await _api.getApi(AppUrls.aboutUs);
      return AboutUsResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<ContactUsResModel> getContactUs() async {
    try {
      final res = await _api.getApi(AppUrls.contactUs);
      return ContactUsResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<PolicyResModel> getPrivacyPolicy() async {
    try {
      final res = await _api.getApi(AppUrls.privacypolicy);
      return PolicyResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<PolicyResModel> getTermsConditions() async {
    try {
      final res = await _api.getApi(AppUrls.termsandcondition);
      return PolicyResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}

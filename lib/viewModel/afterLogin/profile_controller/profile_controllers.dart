import 'package:get/get.dart';

class LanguageController extends GetxController {
  var selectedLanguage = 'Hindi'.obs;

  final List<String> languages = [
    'Hindi',
    'English',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
    'Punjabi',
  ];

  void selectLanguage(String lang) {
    selectedLanguage.value = lang;
  }
}

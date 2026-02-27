import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/profile_controller/profile_controllers.dart';

class SelectLanguageScreen extends StatelessWidget {
  SelectLanguageScreen({super.key});

  final LanguageController controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Select Language',
          style: text18(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          ListView(
            children: [
              // Search field
              Container(
                margin: EdgeInsets.only(top: 15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: decorationBox(30),
                child: TextField(
                  cursorColor: AppColors.textPrimary,
                  textAlignVertical:
                      TextAlignVertical.center, // 👈 center text vertically

                  decoration: InputDecoration(
                    hintText: 'Search language...',
                    hintStyle: text14(),
                    isDense: true, // 👈 removes extra height

                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),

                    prefixIconConstraints: const BoxConstraints(
                      minHeight: 24,
                      minWidth: 40,
                    ), // 👈 centers icon

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 6,
                    ), // 👈 center hint
                    border: InputBorder.none,
                  ),

                  style: const TextStyle(color: AppColors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Language list
              Obx(
                () => Column(
                  children: controller.languages.map((lang) {
                    final isSelected =
                        lang == controller.selectedLanguage.value;

                    return ListTile(
                      title: Text(
                        lang,
                        style: text15(
                          color: isSelected ? AppColors.error : AppColors.white,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.error,
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 15,
                      ),
                      onTap: () {
                        controller.selectLanguage(lang);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

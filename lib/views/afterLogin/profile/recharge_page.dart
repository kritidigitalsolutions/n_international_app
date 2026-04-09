import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/afterLogin/wallet_controller.dart';

class RechargeScreen extends StatelessWidget {
  RechargeScreen({super.key});

  final WalletController controller = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: iconButton(
          icon: Icons.arrow_back_ios_outlined,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Recharge Wallet',
          style: text18(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Money to Wallet', style: text20(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),

                  Text(
                    '1 Rupee = 1 Episode',
                    style: text14(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 25),

                  // 🔥 INPUT FIELD WITH BORDER
                  Obx(() => TextField(
                    controller: controller.amountController,
                    focusNode: controller.amountFocus,
                    keyboardType: TextInputType.number,
                    style: text18(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary),
                      hintText: 'Enter Amount',
                      filled: true,
                      fillColor: AppColors.surface.withAlpha(30),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: controller.isFocused.value ||
                              controller.amountController.text.isNotEmpty
                              ? AppColors.primary
                              : AppColors.error,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      controller.selectedAmount.value = int.tryParse(value) ?? 0;
                    },
                  )),

                  const SizedBox(height: 20),

                  Text('Quick Select', style: text16(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.quickAmounts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      int amount = controller.quickAmounts[index];

                      return Obx(() {
                        bool isSelected = controller.selectedAmount.value == amount;

                        return InkWell(
                          onTap: () => controller.selectAmount(amount),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withAlpha(50),
                              ),
                            ),
                            child: Text(
                              '₹$amount',
                              style: text15(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: decorationBox(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Episodes', style: text14(color: AppColors.textSecondary)),
                            Obx(() => Text(
                              '${controller.selectedAmount.value} Episodes',
                              style: text18(fontWeight: FontWeight.bold),
                            )),
                          ],
                        ),
                        const Icon(Icons.stars, color: AppColors.primary, size: 30),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Obx(() => CustomButton(
                    title: "Continue to Pay",
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.startRecharge(),
                    textColor: AppColors.textPrimary,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

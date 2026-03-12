import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/res/app_images.dart';
import 'package:n_square_international/utils/app_components.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

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
          'Recharge Wallet',
          style: text18(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          backgroundGradient(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Pack',
                    style: text20(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  _buildPackCard(price: '49', episodes: '5', isPremium: false),
                  const SizedBox(height: 12),

                  _buildPackCard(price: '99', episodes: '12', isPremium: false),
                  const SizedBox(height: 12),

                  _buildPackCard(
                    price: '199',
                    episodes: '30',
                    isPremium: false,
                  ),
                  const SizedBox(height: 20),

                  _buildPremiumPack(),
                  const SizedBox(height: 40),

                  Text(
                    'Choose Payment Method',
                    style: text18(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildPaymentIcon(AppImages.gPay),
                      _buildPaymentIcon(AppImages.phonepe),
                      _buildPaymentIcon(AppImages.paytm),
                    ],
                  ),

                  const SizedBox(height: 40),

                  CustomButton(
                    title: "Continue",
                    onPressed: () {},

                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard({
    required String price,
    required String episodes,
    required bool isPremium,
  }) {
    return Container(
      decoration: decorationBox(15),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₹$price', style: text24(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Unlock $episodes Episodes',
                      style: text15(color: AppColors.textSecondary),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: decorationBox(20),
                  child: Text(
                    'Unlock $episodes Episodes',
                    style: text12(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Go Premium',
                  style: text18(
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Go Premium',
                    style: text12(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.lock, color: AppColors.background, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Unlimited Drama Access (30 Days)',
                  style: text15(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₹499',
              style: text24(
                fontWeight: FontWeight.bold,
                color: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIcon(String asset) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Image.asset(
        asset,
        width: 80,
        height: 40,
        errorBuilder: (_, __, ___) => const Icon(Icons.payment, size: 40),
      ),
    );
  }
}

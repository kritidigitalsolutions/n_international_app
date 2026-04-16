import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/repo/wallet_repo.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';
import 'package:n_square_international/viewModel/afterLogin/user_controller/full_profile_controller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../res/app_colors.dart';

class WalletController extends GetxController {
  final WalletRepo _walletRepo = WalletRepo();
  final amountController = TextEditingController();
  final Razorpay _razorpay = Razorpay();

  var isLoading = false.obs;
  var selectedAmount = 0.obs;

  // 🔥 Focus handling
  final FocusNode amountFocus = FocusNode();
  var isFocused = false.obs;

  final List<int> quickAmounts = [50, 100, 150, 200, 250, 300];

  @override
  void onInit() {
    super.onInit();

    amountFocus.addListener(() {
      isFocused.value = amountFocus.hasFocus;
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    amountController.dispose();
    amountFocus.dispose();
    super.onClose();
  }

  void selectAmount(int amount) {
    selectedAmount.value = amount;
    amountController.text = amount.toString();
  }

  Future<void> startRecharge() async {
    String amountStr = amountController.text.trim();

    if (amountStr.isEmpty) {
      CustomSnackbar.showError(title: "Error", message: "Please enter amount");
      return;
    }

    int amount = int.tryParse(amountStr) ?? 0;

    if (amount < 10) {
      CustomSnackbar.showError(
        title: "Error",
        message: "Minimum recharge amount is ₹10",
      );
      return;
    }

    isLoading.value = true;

    try {
      final data = {"amount": amount};
      final response = await _walletRepo.createOrder(data);

      if (response['success'] == true) {
        final order = response['order'];
        _openRazorpay(order);
      } else {
        CustomSnackbar.showError(
          title: "Error",
          message: response['message'] ?? "Failed to create order",
        );
      }
    } catch (e) {
      CustomSnackbar.showError(title: "Error", message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _openRazorpay(Map<String, dynamic> order) {
    final profile = Get.find<FullProfileController>();

    var options = {
      'key': order['keyId'],
      'amount': order['amountInPaise'],
      'name': 'N Square International',
      'order_id': order['razorpayOrderId'],
      'description': 'Recharge Wallet',
      'prefill': {
        'contact': profile.phone.value,
        'email': profile.email.value,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  // ✅ SUCCESS HANDLER
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    isLoading.value = true;

    try {
      final data = {
        "razorpay_order_id": response.orderId,
        "razorpay_payment_id": response.paymentId,
        "razorpay_signature": response.signature,
      };

      final result = await _walletRepo.verifyPayment(data);

      if (result['success'] == true) {
        // 🔥 SUCCESS POPUP
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Icon Circle
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ✅ Title
                  Text(
                    "Payment Successful 🎉",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ✅ Message
                  Text(
                    "Your wallet has been updated successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // dialog
                        Get.back(); // screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Update profile
        if (Get.isRegistered<FullProfileController>()) {
          Get.find<FullProfileController>().fetchUserProfile();
        }
      } else {
        _showFailPopup(result['message'] ?? "Payment verification failed");
      }
    } catch (e) {
      _showFailPopup(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ❌ ERROR HANDLER
  void _handlePaymentError(PaymentFailureResponse response) {
    _showFailPopup(response.message ?? "Payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackbar.showInfo(
      title: "External Wallet",
      message: response.walletName ?? "Selected",
    );
  }

  // 🔥 COMMON FAIL POPUP
  void _showFailPopup(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ❌ Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 40,
                ),
              ),

              const SizedBox(height: 15),

              // ❌ Title
              Text(
                "Payment Failed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // ❌ Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // ❌ Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

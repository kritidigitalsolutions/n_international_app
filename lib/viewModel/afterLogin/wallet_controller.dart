import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n_square_international/repo/wallet_repo.dart';
import 'package:n_square_international/utils/custom_snakebar.dart';
import 'package:n_square_international/viewModel/afterLogin/user_controller/full_profile_controller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class WalletController extends GetxController {
  final WalletRepo _walletRepo = WalletRepo();
  final amountController = TextEditingController();
  final Razorpay _razorpay = Razorpay();

  var isLoading = false.obs;
  var selectedAmount = 0.obs;

  final List<int> quickAmounts = [50, 100, 150, 200, 250, 300];

  @override
  void onInit() {
    super.onInit();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    amountController.dispose();
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
    if (amount <= 0) {
      CustomSnackbar.showError(title: "Error", message: "Please enter a valid amount");
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
        CustomSnackbar.showError(title: "Error", message: response['message'] ?? "Failed to create order");
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
        CustomSnackbar.showSuccess(title: "Success", message: "Payment successful and wallet updated");
        
        // 🔥 UPDATE PROFILE & BALANCE IMMEDIATELY
        if (Get.isRegistered<FullProfileController>()) {
          Get.find<FullProfileController>().fetchUserProfile();
        }
        
        Get.back();
      } else {
        CustomSnackbar.showError(title: "Error", message: result['message'] ?? "Payment verification failed");
      }
    } catch (e) {
      CustomSnackbar.showError(title: "Error", message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CustomSnackbar.showError(title: "Payment Failed", message: response.message ?? "Something went wrong");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackbar.showInfo(title: "External Wallet", message: response.walletName ?? "Selected");
  }
}

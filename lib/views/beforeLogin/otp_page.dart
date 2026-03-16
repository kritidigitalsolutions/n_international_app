import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';
import 'package:n_square_international/viewModel/beforeLogin/auth_controller.dart';
import 'package:n_square_international/views/beforeLogin/login_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final OtpController controller = Get.put(OtpController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => OtpTextField(
                    index: index,
                    controller: controller.otpControllers[index],
                    focusNode: controller.focusNodes[index],
                    onChanged: (value) => controller.onOtpChanged(value, index),
                    onBackspace: controller.handleBackspace,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Obx(
                () => CustomGradientButton(
                  title: "Continue",
                  isLoading: controller.isLoading.value,
                  onPressed: controller.submitOtp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpTextField extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(int) onBackspace;

  const OtpTextField({
    super.key,
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 55,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace(index);
          }
        },
        child: Container(
          decoration: decorationBox(5),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            cursorColor: AppColors.textPrimary,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: text18(fontWeight: FontWeight.bold),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: "",

              border: InputBorder.none,
            ),
            onChanged: (value) => onChanged(value),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/custom_button.dart';
import 'package:n_square_international/utils/textStyle.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentRed, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        style: text15(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        validator: validator,
        cursorColor: AppColors.textPrimary,
        decoration: InputDecoration(
          counterText: "",
          hintText: hintText,

          hintStyle: const TextStyle(color: AppColors.textSecondary),

          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,

          filled: true,
          fillColor: Colors.transparent, // important

          border: InputBorder.none,

          errorStyle: text12(color: AppColors.error),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class CustomPhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const CustomPhoneTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.phone,
    this.obscureText = false,
    this.maxLength = 10,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decorationBox(30),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        cursorColor: AppColors.textPrimary,
        maxLength: maxLength,
        style: text15(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength),
        ],
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return "Please enter phone number";
              }
              if (value.length != 10) {
                return "Enter valid 10 digit number";
              }
              return null;
            },
        decoration: InputDecoration(
          counterText: "",
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon:
              prefixIcon ??
              const Icon(Icons.phone, color: AppColors.textSecondary),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.transparent,
          border: InputBorder.none,
          errorStyle: text12(color: AppColors.error),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

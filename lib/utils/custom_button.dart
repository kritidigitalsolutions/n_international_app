import 'package:flutter/material.dart';
import 'package:n_square_international/res/app_colors.dart';
import 'package:n_square_international/utils/textStyle.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final Color? color;
  final Color textColor;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.height = 48,
    this.borderRadius = 20,
    this.textColor = AppColors.textPrimary,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: decorationBox(borderRadius),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
            : Text(
                title,
                style: text15(fontWeight: FontWeight.w600, color: textColor),
              ),
      ),
    );
  }
}

/// ================= OUTLINE BUTTON =================
class CustomOutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;

  const CustomOutlineButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.borderColor = AppColors.white,
    this.textColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(title, style: text14(color: textColor)),
    );
  }
}

/// ================= TEXT BUTTON =================
class CustomTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color textColor;

  const CustomTextButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.textColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: text14(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class CustomGradientButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final List<Color> gradientColors;
  final Widget? icon;

  const CustomGradientButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.height = 40,
    this.borderRadius = 30,
    this.icon,
    this.gradientColors = const [AppColors.accentRed, AppColors.primary],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: decorationBox(borderRadius),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(title, style: text15(color: AppColors.white)),
                ],
              ),
      ),
    );
  }
}

Widget iconButton({
  required IconData icon,
  required VoidCallback onPressed,
  Color color = AppColors.white,
  double size = 20,
}) {
  return IconButton(
    onPressed: onPressed,
    icon: Icon(icon, color: color, size: size),
  );
}

Widget circleIconButton({
  required IconData icon,
  required VoidCallback onPressed,
  Color color = AppColors.white,
  Color background = AppColors.card,
  double radius = 15,
  double size = 20,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: Icon(icon, color: color, size: size),
    ),
  );
}

BoxDecoration decorationBox(double borderRadius) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),

    // Border like your image
    border: Border.all(color: AppColors.white.withAlpha(50), width: 1),

    // Glow shadow
    boxShadow: [
      BoxShadow(
        color: AppColors.buttonColor,
        blurRadius: 50, // glow softness
        spreadRadius: -4, // glow size
        offset: const Offset(0, 4),
      ),
    ],

    color: AppColors.background.withAlpha(100),
  );
}

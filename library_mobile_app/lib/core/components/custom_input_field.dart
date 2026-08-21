import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      cursorColor: AppColors.primary,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? AppColors.inputDark
            : AppColors.backgroundLight,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppColors.textDark.withOpacity(0.35)
              : AppColors.textLight.withOpacity(0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}
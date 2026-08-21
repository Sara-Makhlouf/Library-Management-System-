import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class CustomButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final String text;

  const CustomButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor:
              AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
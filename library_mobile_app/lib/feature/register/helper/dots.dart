import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class StepDots extends StatelessWidget {
  final int currentStep;
  final bool isDark;

  const StepDots({super.key, required this.currentStep, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) {
      return Container(
        width: 26,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary
              : (isDark ? Colors.white12 : Colors.black12),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [dot(currentStep >= 0), dot(currentStep >= 1)],
    );
  }
}

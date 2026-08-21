import 'package:flutter/material.dart';

class OnboardingDot extends StatelessWidget {
  final bool isActive;

  const OnboardingDot({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
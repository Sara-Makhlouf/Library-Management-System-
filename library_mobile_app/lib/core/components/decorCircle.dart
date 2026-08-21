import 'package:flutter/material.dart';

class DecorCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const DecorCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:library_mobile_app/feature/register/helper/colors.dart';

Widget buildIcon() {
  return Container(
    width: 84,
    height: 84,

    decoration: BoxDecoration(
      shape: BoxShape.circle,

      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [OtpColors.primaryStart, OtpColors.primaryEnd],
      ),

      boxShadow: [
        BoxShadow(
          color: OtpColors.primaryStart.withOpacity(0.28),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),

    child: const Icon(Icons.chat_rounded, size: 38, color: Colors.white),
  );
}

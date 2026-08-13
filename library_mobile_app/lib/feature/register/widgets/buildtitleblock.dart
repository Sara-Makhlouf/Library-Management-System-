import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:library_mobile_app/feature/register/helper/colors.dart';

Widget buildTitleBlock() {
  return Column(
    children: [
      const Text(
        'Enter verification code',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: OtpColors.ink,
          letterSpacing: -0.3,
        ),
      ),

      const SizedBox(height: 10),

      RichText(
        textAlign: TextAlign.center,

        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: OtpColors.inkMuted,
          ),

          children: [
            const TextSpan(text: 'We sent a 6-digit code to WhatsApp\n'),
          ],
        ),
      ),
    ],
  );
}

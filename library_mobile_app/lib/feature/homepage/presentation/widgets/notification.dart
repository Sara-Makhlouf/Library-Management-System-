import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/constantPage.dart';
import 'package:library_mobile_app/core/theme.dart';

class CustomNotificationButton extends StatelessWidget {
  const CustomNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 50,
      height: 50,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.notifications_none,
          color: isDark ? AppColors.primary : AppColors.secondary,
          size: 30,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.notifications);
        },
      ),
    );
  }
}

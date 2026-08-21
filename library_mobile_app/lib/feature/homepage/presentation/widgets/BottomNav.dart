import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:library_mobile_app/core/theme.dart'; // تأكد من استيراد ملف الألوان الخاص بك

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CurvedNavigationBar(
      index: currentIndex,
      height: 55.0,
      items: <Widget>[
        Icon(
          Icons.favorite,
          size: 30,

          color: isDark ? AppColors.primary : AppColors.textGrey,
        ),
        Icon(
          Icons.home,
          size: 40,
          color: isDark ? AppColors.primary : AppColors.textGrey,
        ),
        Icon(
          Icons.shopping_cart,
          size: 30,
          color: isDark ? AppColors.primary : AppColors.textGrey,
        ), // index 2: Cart
      ],

      color: isDark ? AppColors.darkCard : AppColors.secondary,

      buttonBackgroundColor: isDark ? AppColors.inputDark : AppColors.secondary,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap,
    );
  }
}

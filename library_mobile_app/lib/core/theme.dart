import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFB8A068);
  static const Color secondary = Color.fromARGB(255, 189, 170, 127);
  static const Color accent = Color(0xFFD8C8A8);
  static const Color background = Color.fromARGB(255, 234, 226, 218);
  static const Color textGrey = Color.fromARGB(255, 96, 82, 50);
  static const Color iconical = Colors.grey; //
  static const Color primacy = Color(0xFFB8A068);
  static const Color backgroundLight = Color(0xFFEAE2DA);
  static const Color accentLight = Color(0xFFD8C8A8);
  static const Color inputLight = Colors.white; // خلفية حقل الإدخال
  static const Color iconLight = Color(0xFF685A39); // أيقونات الحقل
  static const Color textLight = Color(0xFF605232); // النصوص الفاتحة

  // ================= (الوضع الداكن - Dark Mode) =================
  // الألوان المستخرجة بدقة من تصميمك
  static const Color backgroundDark = Color(
    0xFF181612,
  ); // خلفية التطبيق الداكنة
  static const Color accentDark = Color(0xFF23201B); // الهيدر العلوي
  static const Color inputDark = Color(0xFF2E2A25); // خلفية حقل الإدخال بالدارك
  static const Color iconDark = Color(
    0xFFB8A068,
  ); // استخدمت الذهبي الأساسي ليكون بارز، أو فيك تحط (0xFFEAE2DA) إذا بدك ياه نفس لون النص
  static const Color textDark = Color(0xFFEAE2DA);
  static const Color darkCard = Color(0xFF26221D);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textLight),
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputLight,
      prefixIconColor: AppColors.iconLight,
      hintStyle: const TextStyle(color: AppColors.textLight),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputDark,
      prefixIconColor: AppColors.primary,
      hintStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

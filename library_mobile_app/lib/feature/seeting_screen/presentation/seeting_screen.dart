// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme_cubit.dart';
import 'package:library_mobile_app/core/locale_cubit.dart'; // استيراد كابيت اللغة الخاص بكِ
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // قراءة اللغة الحالية الفعّالة في التطبيق
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      // ─── تكييف خلفية الشاشة بالكامل مع الثيمين ───
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFEFE3D3),
      appBar: AppBar(
        // تعديل: تحويل العنوان ليكون مترجماً ديناميكياً
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        // ─── تكييف الـ AppBar مع درجات الهيدر المتناسقة ───
        backgroundColor: isDark
            ? AppColors.darkCard
            : const Color.fromARGB(255, 189, 170, 127),
        foregroundColor: isDark
            ? AppColors.primary
            : const Color.fromARGB(255, 96, 82, 50),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1️⃣ بطاقة خيار تفعيل الوضع الليلي/النهاري
          Card(
            elevation: isDark ? 1 : 3,
            color: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: isDark
                  ? BorderSide(color: AppColors.textGrey.withOpacity(0.1))
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
                size: 26,
              ),
              title: Text(
                isDark
                    ? AppLocalizations.of(context)!.darkMode
                    : AppLocalizations.of(context)!.lightMode,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? AppColors.textDark : Colors.black87,
                ),
              ),
              trailing: Switch(
                value: isDark,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: const Color.fromARGB(255, 96, 82, 50),
                inactiveTrackColor: const Color.fromARGB(
                  255,
                  189,
                  170,
                  127,
                ).withOpacity(0.4),
                onChanged: (bool value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ),
          ),

          const SizedBox(height: 12), // مسافة فاصلة بين البطاقتين
          // 2️⃣ بطاقة خيار تغيير لغة التطبيق (العربية / الإنجليزية)
          Card(
            elevation: isDark ? 1 : 3,
            color: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: isDark
                  ? BorderSide(color: AppColors.textGrey.withOpacity(0.1))
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Icon(
                Icons.language_rounded,
                color: AppColors.primary,
                size: 26,
              ),
              title: Text(
                currentLocale.languageCode == 'ar'
                    ? 'لغة التطبيق'
                    : 'App Language',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? AppColors.textDark : Colors.black87,
                ),
              ),
              // عرض اسم اللغة الحالية تحت العنوان الرئيسي للبطاقة
              subtitle: Text(
                currentLocale.languageCode == 'ar' ? 'العربية' : 'English',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.6)
                      : Colors.black54,
                ),
              ),
              // القائمة المنسدلة لاختيار وتغيير اللغة
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLocale.languageCode,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : Colors.black87,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // استدعاء دالة تغيير اللغة داخل الـ LocaleCubit لتحديث واجهة التطبيق فوراً
                      context.read<LocaleCubit>().changeLanguage(newValue);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

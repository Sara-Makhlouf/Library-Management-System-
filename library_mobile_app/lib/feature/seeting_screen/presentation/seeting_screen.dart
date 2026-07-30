// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme_cubit.dart';
import 'package:library_mobile_app/core/locale_cubit.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── بطاقة إعدادات الحساب ──
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Column(
              children: [
                // زر الوضع الليلي
                _buildSettingsTile(
                  icon: isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  label: isDark
                      ? AppLocalizations.of(context)!.darkMode
                      : AppLocalizations.of(context)!.lightMode,
                  isDark: isDark,
                  trailing: Switch(
                    value: isDark,
                    onChanged: (bool value) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    activeColor: AppColors.primary,
                  ),
                ),

                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.06),
                ),

                // لغة التطبيق
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  label: currentLocale.languageCode == 'ar'
                      ? 'لغة التطبيق'
                      : 'App Language',
                  isDark: isDark,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentLocale.languageCode,
                      icon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          context.read<LocaleCubit>().changeLanguage(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final color = isDark ? AppColors.textDark : AppColors.textLight;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 15, color: color.withOpacity(0.65)),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: trailing,
    );
  }
}

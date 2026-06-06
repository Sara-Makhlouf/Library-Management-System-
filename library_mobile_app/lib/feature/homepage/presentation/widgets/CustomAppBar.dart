import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ───
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      // ─── التعديل: تغيير لون الخلفية في الدارك مود ───
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Hi',
        style: TextStyle(
          // ─── التعديل: تغيير لون نص العنوان ليصبح فاتحاً في الدارك مود ───
          color: isDark ? AppColors.textDark : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            // يبقى الذهبي الأساسي بالوضعين لأنه بارز ومناسب
            color: AppColors.primary,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
          onPressed: () {
            print('Notifications pressed');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

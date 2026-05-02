import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Hi',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
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

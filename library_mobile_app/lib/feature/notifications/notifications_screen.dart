import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/notifications/notification_card.dart';
import 'package:library_mobile_app/feature/notifications/notification_cubit.dart';
import 'package:library_mobile_app/feature/notifications/notification_repository.dart';
import 'package:library_mobile_app/feature/notifications/notification_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => NotificationCubit(NotificationRepository())..getNotifications(),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                  ),
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(
                  child: Text(
                    'No new notifications',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return NotificationCard(
                    title: item.title,
                    body: item.body,
                    time: item.time,
                    isDark: isDark,
                  );
                },
              );
            }

            return Center(
              child: Text(
                'No new notifications',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

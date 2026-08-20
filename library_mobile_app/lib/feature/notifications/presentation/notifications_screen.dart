import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/notifications/presentation/widgets/notification_card.dart';
import 'package:library_mobile_app/feature/notifications/bloc/notification_cubit.dart';
import 'package:library_mobile_app/feature/notifications/repo/notification_repository.dart';
import 'package:library_mobile_app/feature/notifications/bloc/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) =>
          NotificationCubit(NotificationRepository())..getNotifications(),

      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,

            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,

              title: Text(
                'Notifications',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),

              centerTitle: true,

              iconTheme: IconThemeData(
                color: isDark ? Colors.white : Colors.black,
              ),

              actions: [
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    if (state is! NotificationLoaded) {
                      return const SizedBox();
                    }

                    final unread = state.notifications
                        .where((n) => !n.isRead)
                        .length;

                    if (unread == 0) {
                      return const SizedBox();
                    }

                    return TextButton.icon(
                      onPressed: () async {
                        //  await context.read<NotificationCubit>().markAllAsRead();
                      },

                      icon: const Icon(Icons.done_all_rounded, size: 18),

                      label: const Text(
                        'Read all',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ],

              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),

                  child: Container(
                    height: 48,

                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(.06)
                          : Colors.black.withOpacity(.04),

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: TabBar(
                      controller: _tabController,

                      dividerColor: Colors.transparent,

                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      indicatorSize: TabBarIndicatorSize.tab,

                      labelColor: Colors.white,

                      unselectedLabelColor: isDark
                          ? Colors.white54
                          : Colors.black54,

                      tabs: const [
                        Tab(
                          icon: Icon(
                            Icons.notifications_active_outlined,
                            size: 19,
                          ),
                          text: 'Unread',
                        ),
                        Tab(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            size: 19,
                          ),
                          text: 'Read',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            body: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotificationError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(state.message, textAlign: TextAlign.center),
                    ),
                  );
                }

                if (state is NotificationLoaded) {
                  final unread = state.notifications
                      .where((n) => !n.isRead)
                      .toList();

                  final read = state.notifications
                      .where((n) => n.isRead)
                      .toList();

                  return TabBarView(
                    controller: _tabController,

                    children: [
                      _buildNotificationList(
                        context,
                        unread,
                        isDark,
                        emptyText: 'No unread notifications',
                      ),

                      _buildNotificationList(
                        context,
                        read,
                        isDark,
                        emptyText: 'No read notifications',
                      ),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    List notifications,
    bool isDark, {
    required String emptyText,
  }) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 60,
              color: isDark ? Colors.white24 : Colors.black12,
            ),

            const SizedBox(height: 12),

            Text(
              emptyText,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: notifications.length,

      itemBuilder: (context, index) {
        final item = notifications[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),

          child: NotificationCard(
            title: item.title,
            body: item.body,
            time: item.time,
            isDark: isDark,
            // isRead: item.isRead,

            /*   onTap: () {
              if (!item.isRead) {
              //  context.read<NotificationCubit>().markAsRead(item.id);
              }
            },*/
          ),
        );
      },
    );
  }
}

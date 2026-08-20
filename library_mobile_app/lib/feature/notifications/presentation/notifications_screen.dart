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

      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,

        // =====================================================
        // APP BAR
        // =====================================================
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

          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),

          actions: [
            // =================================================
            // READ ALL
            // =================================================
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is! NotificationLoaded) {
                  return const SizedBox();
                }

                if (state.unreadCount == 0) {
                  return const SizedBox();
                }

                return TextButton.icon(
                  onPressed: () async {
                    await context.read<NotificationCubit>().markAllAsRead();

                    // نرجع تلقائياً على Unread
                    _tabController.animateTo(0);
                  },

                  icon: const Icon(
                    Icons.done_all_rounded,
                    size: 19,
                    color: Colors.red,
                  ),

                  label: const Text(
                    'Read all',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ],

          // ===================================================
          // TABS
          // ===================================================
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(65),

            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

              child: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  int unreadCount = 0;
                  int readCount = 0;

                  if (state is NotificationLoaded) {
                    unreadCount = state.notifications
                        .where((n) => !n.isRead)
                        .length;

                    readCount = state.notifications
                        .where((n) => n.isRead)
                        .length;
                  }

                  return Container(
                    height: 50,

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

                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_active_outlined,
                                size: 18,
                              ),

                              const SizedBox(width: 7),

                              const Text('Unread'),

                              if (unreadCount > 0) ...[
                                const SizedBox(width: 6),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                size: 18,
                              ),

                              const SizedBox(width: 7),

                              const Text('Read'),

                              if (readCount > 0) ...[
                                const SizedBox(width: 6),

                                Text(
                                  readCount.toString(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // =====================================================
        // BODY
        // =====================================================
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            // =================================================
            // LOADING
            // =================================================

            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // =================================================
            // ERROR
            // =================================================

            if (state is NotificationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 55,
                        color: Colors.red.withOpacity(.7),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        state.message,
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: () {
                          context.read<NotificationCubit>().getNotifications();
                        },

                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // =================================================
            // LOADED
            // =================================================

            if (state is NotificationLoaded) {
              final unread = state.notifications
                  .where((n) => !n.isRead)
                  .toList();

              final read = state.notifications.where((n) => n.isRead).toList();

              return TabBarView(
                controller: _tabController,

                children: [
                  // ==========================================
                  // UNREAD
                  // ==========================================
                  _buildNotificationList(
                    context,
                    unread,
                    isDark,
                    emptyText: 'No unread notifications',
                  ),

                  // ==========================================
                  // READ
                  // ==========================================
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
      ),
    );
  }

  // ===========================================================
  // NOTIFICATION LIST
  // ===========================================================

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
              size: 65,
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

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NotificationCubit>().refreshNotifications();
      },

      child: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: notifications.length,

        itemBuilder: (context, index) {
          final item = notifications[index];

          return NotificationCard(
            id: item.id,
            title: item.title,
            body: item.body,
            time: item.time,
            isDark: isDark,
            isRead: item.isRead,

            // ================================================
            // PRESS NOTIFICATION
            // ================================================
            onTap: () async {
              if (!item.isRead) {
                await context.read<NotificationCubit>().markAsRead(item.id);
              }

              if (!context.mounted) return;

              // إذا بدك ينتقل لصفحة الإشعارات
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );

              // إذا عندك target_screen بالـ Model
              // فينا لاحقاً نضيف navigation هون.
            },
          );
        },
      ),
    );
  }
}

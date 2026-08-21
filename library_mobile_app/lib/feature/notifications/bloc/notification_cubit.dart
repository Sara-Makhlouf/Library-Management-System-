import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/notification_repository.dart';
import 'notification_model.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  // ============================================================
  // GET NOTIFICATIONS
  // ============================================================

  Future<void> getNotifications() async {
    emit(NotificationLoading());

    try {
      final notifications = await _repository.getNotifications();

      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );

      debugPrint('🔔 Notifications: ${notifications.length}');

      debugPrint('🔴 Unread: $unreadCount');
    } catch (e) {
      emit(NotificationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ============================================================
  // REFRESH UNREAD COUNT ONLY
  // ============================================================

  Future<void> refreshUnreadCount() async {
    try {
      final unreadCount = await _repository.getUnreadCount();

      final currentState = state;

      if (currentState is NotificationLoaded) {
        emit(
          NotificationLoaded(
            notifications: currentState.notifications,
            unreadCount: unreadCount,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh unread count: $e');
    }
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<void> markAsRead(int id) async {
    final currentState = state;

    if (currentState is! NotificationLoaded) {
      return;
    }

    try {
      await _repository.markAsRead(id);

      final updatedNotifications = currentState.notifications.map((
        notification,
      ) {
        if (notification.id == id) {
          return notification.copyWith(isRead: true);
        }

        return notification;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      emit(
        NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ),
      );

      debugPrint('✅ Notification $id marked as read');

      debugPrint('🔴 Remaining unread: $unreadCount');
    } catch (e) {
      debugPrint('❌ MARK AS READ ERROR: $e');
    }
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead() async {
    final currentState = state;

    if (currentState is! NotificationLoaded) {
      return;
    }

    try {
      await _repository.markAllAsRead();

      final updatedNotifications = currentState.notifications.map((
        notification,
      ) {
        return notification.copyWith(isRead: true);
      }).toList();

      emit(
        NotificationLoaded(notifications: updatedNotifications, unreadCount: 0),
      );

      print('✅ ALL NOTIFICATIONS MARKED AS READ');
      print('🔴 UNREAD COUNT: 0');
    } catch (e) {
      print('❌ MARK ALL AS READ ERROR: $e');
    }
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshNotifications() async {
    await getNotifications();
  }
}

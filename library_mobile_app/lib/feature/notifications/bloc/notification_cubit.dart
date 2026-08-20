import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/notification_repository.dart';
import 'notification_model.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  // =========================================================
  // GET NOTIFICATIONS + UNREAD COUNT
  // =========================================================

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

      print('🔔 NOTIFICATIONS: ${notifications.length}');
      print('🔴 UNREAD COUNT: $unreadCount');
    } catch (e) {
      emit(NotificationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // =========================================================
  // MARK ONE AS READ
  // =========================================================

  Future<void> markAsRead(int id) async {
    final currentState = state;

    if (currentState is! NotificationLoaded) {
      return;
    }

    try {
      // أولاً نرسل للباك
      await _repository.markAsRead(id);

      // نحدث القائمة محلياً
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

      print('✅ Notification $id marked as read');
      print('🔴 Remaining unread: $unreadCount');
    } catch (e) {
      print('❌ MARK AS READ ERROR: $e');
    }
  }

  // =========================================================
  // MARK ALL AS READ
  // =========================================================

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

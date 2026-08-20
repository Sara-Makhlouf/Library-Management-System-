import 'notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  NotificationLoaded(this.notifications);

  final List<NotificationModel> notifications;
}

class NotificationError extends NotificationState {
  NotificationError(this.message);

  final String message;
}

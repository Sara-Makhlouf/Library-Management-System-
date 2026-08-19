import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  Future<void> getNotifications() async {
    emit(NotificationLoading());

    try {
      final notifications = await _repository.getNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

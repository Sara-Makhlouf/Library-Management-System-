import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/logout/bloc/logout_event.dart';
import 'package:library_mobile_app/feature/logout/bloc/logout_state.dart';
import 'package:library_mobile_app/feature/logout/repo/logout_repo.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutRepository repository;

  LogoutBloc({required this.repository}) : super(LogoutInitial()) {
    on<LogoutRequested>((event, emit) async {
      emit(LogoutLoading());
      try {
        await repository.logout();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure(e.toString()));
      }
    });
  }
}

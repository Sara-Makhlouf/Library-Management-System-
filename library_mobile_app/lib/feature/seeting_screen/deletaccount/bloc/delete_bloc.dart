import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/feature/seeting_screen/deletaccount/bloc/delete_event.dart';
import 'package:library_mobile_app/feature/seeting_screen/deletaccount/bloc/delete_state.dart';
import 'package:library_mobile_app/feature/seeting_screen/deletaccount/repo/delete_repo.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountRepository repository;

  DeleteAccountBloc({required this.repository})
    : super(DeleteAccountInitial()) {
    on<DeleteAccountRequested>(_onDeleteAccount);
  }

  Future<void> _onDeleteAccount(
    DeleteAccountRequested event,
    Emitter<DeleteAccountState> emit,
  ) async {
    emit(DeleteAccountLoading());

    try {
      await repository.deleteAccount(event.phone);

      emit(DeleteAccountSuccess());
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();

      emit(
        DeleteAccountFailure(
          message.isEmpty ? 'Failed to delete account' : message,
        ),
      );
    }
  }
}

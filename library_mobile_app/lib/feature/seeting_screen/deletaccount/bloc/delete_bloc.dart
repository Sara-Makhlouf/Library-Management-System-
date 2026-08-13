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
      await repository.deleteAccount();

      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(DeleteAccountFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

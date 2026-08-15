import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/register_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository repository;

  RegisterBloc({required this.repository}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    try {
      final result = await repository.register(
        registerData: event.registerData,
      );

      emit(RegisterSuccess(data: result));
    } catch (e) {
      String message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      emit(RegisterFailure(message: message));
    }
  }
}

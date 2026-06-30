import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/register/bloc/register_event.dart';
import 'package:library_mobile_app/feature/register/bloc/register_state.dart';
import 'package:library_mobile_app/feature/register/data/register_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository repository;

  RegisterBloc({required this.repository}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      final result = await repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
        gender: event.gender,
        phone: event.phone,
        dob: event.dob,
        lang: event.lang,
        fcmToken: event.fcmToken,
      );
      emit(RegisterSuccess(result));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}

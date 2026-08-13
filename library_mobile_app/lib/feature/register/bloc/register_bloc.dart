import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:library_mobile_app/core/constants.dart';

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

      print('====================================');
      print('🟢 Register Success');
      print('🟢 Response: $result');
      print('====================================');

      String token = '';

      final data = result['data'];

      if (data is Map) {
        token = data['token']?.toString() ?? '';
      }

      if (token.isEmpty) {
        token = result['token']?.toString() ?? '';
      }

      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(tokenKey, token);

        print('🟢 Token saved');
      }

      emit(RegisterSuccess(result));
    } catch (e) {
      print('====================================');
      print('🔴 Register Failure');
      print('🔴 Error: $e');
      print('====================================');

      String message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      emit(RegisterFailure(message));
    }
  }
}

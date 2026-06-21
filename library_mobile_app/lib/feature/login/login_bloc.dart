import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import 'login_event.dart';
import 'login_repository.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repository;

  LoginBloc({required this.repository}) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      print('🔵 Login event received: phone/email=${event.phone}, password length=${event.password.length}');
      emit(LoginLoading());
      try {
        final data = await repository.login(event.phone, event.password, event.fcm_token);
        print('🔵 Login succeeded, emitting LoginSuccess');
        final responseData = (data['data'] as Map<String, dynamic>?) ?? {};

        final token = responseData['token']?.toString() ?? '';
        final name = responseData['name']?.toString() ?? '';
        final type = responseData['type']?.toString() ?? '';
        final pointsBalance = responseData['points_balance'] is int
            ? responseData['points_balance'] as int
            : int.tryParse(responseData['points_balance']?.toString() ?? '') ?? 0;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        emit(LoginSuccess(
          token: token,
          name: name,
          type: type,
          pointsBalance: pointsBalance,
        ));
      } catch (e) {
        print('🔵 Login failed, emitting LoginFailure: ${e.toString()}');
        emit(LoginFailure(message: e.toString()));
      }
    });
  }
}

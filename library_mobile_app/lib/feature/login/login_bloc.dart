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
      emit(LoginLoading());
      try {
        final data = await repository.login(event.phone, event.password, event.fcm_token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, data['token']);
        await prefs.setString(userKey, jsonEncode(data['user']));
        emit(LoginSuccess(token: data['token'], user: data['user']));
      } catch (e) {
        emit(LoginFailure(message: e.toString()));
      }
    });
  }
}

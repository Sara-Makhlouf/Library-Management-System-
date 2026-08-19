import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/profile/data/customer_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:library_mobile_app/core/constants.dart';

import '../data/register_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository repository;
  final CustomerRepository customerRepository;

  RegisterBloc({required this.repository, required this.customerRepository})
    : super(RegisterInitial()) {
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

     

      final data = result['data'];

      if (data == null || data is! Map) {
        throw Exception(
          'Account created successfully, but response data is missing.',
        );
      }

 

      final token = data['token']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Account created successfully, but no authentication token was returned.',
        );
      }


      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(tokenKey, token);

      print('================================');
      print('✅ AUTH TOKEN SAVED');
      print('TOKEN: $token');
      print('KEY: $tokenKey');
      print('================================');

    

      final profileResponse = await customerRepository.getProfile();

      print('================================');
      print('🟢 PROFILE RESPONSE');
      print(profileResponse);
      print('================================');

   

      await prefs.setString(userKey, jsonEncode(profileResponse));

      print('================================');
      print('✅ USER DATA SAVED');
      print('KEY: $userKey');
      print('================================');

    

      emit(RegisterSuccess(data: {...result, 'profile': profileResponse}));
    } catch (e) {
      print('================================');
      print('❌ REGISTER ERROR');
      print(e);
      print('================================');

      String message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      emit(RegisterFailure(message: message));
    }
  }
}

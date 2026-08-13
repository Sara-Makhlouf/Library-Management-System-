import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String gender;
  final String phone;
  final String dob;
  final String? lang;
  final String? fcmToken;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.gender,
    required this.phone,
    required this.dob,
    this.lang,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    passwordConfirmation,
    gender,
    phone,
    dob,
    lang,
    fcmToken,
  ];
}

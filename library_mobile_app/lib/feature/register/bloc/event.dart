import 'dart:io';

abstract class AuthEvent {}

class RegisterSubmittedEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final File? avatar;

  RegisterSubmittedEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.avatar,
  });
}

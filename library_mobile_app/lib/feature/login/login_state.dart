abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final Map<String, dynamic> user;

  LoginSuccess({required this.token, required this.user});
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});
}

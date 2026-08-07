abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final String name;
  final String type;
  final int pointsBalance;

  LoginSuccess({
    required this.token,
    required this.name,
    required this.type,
    required this.pointsBalance,
  });
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});
}

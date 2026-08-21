abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String phone;
  final String password;
  final String fcm_token;

  LoginSubmitted({required this.phone, required this.password, required this.fcm_token});
}

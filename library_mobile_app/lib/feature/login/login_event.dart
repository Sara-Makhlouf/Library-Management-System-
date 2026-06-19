abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String phone;
  final String password;
  final String fcmToken;

  LoginSubmitted({required this.phone, required this.password, required this.fcmToken});
}

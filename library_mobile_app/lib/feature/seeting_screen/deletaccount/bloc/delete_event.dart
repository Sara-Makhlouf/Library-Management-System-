abstract class DeleteAccountEvent {}

class DeleteAccountRequested extends DeleteAccountEvent {
  final String phone;

  DeleteAccountRequested({required this.phone});
}

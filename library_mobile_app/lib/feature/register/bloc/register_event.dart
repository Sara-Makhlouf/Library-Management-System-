import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final Map<String, dynamic> registerData;

  const RegisterSubmitted({required this.registerData});

  @override
  List<Object?> get props => [registerData];
}

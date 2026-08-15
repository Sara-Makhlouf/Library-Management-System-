import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final Map<String, dynamic> data;

  const RegisterSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

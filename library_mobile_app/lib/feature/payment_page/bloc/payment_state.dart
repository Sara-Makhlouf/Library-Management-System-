import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- States ---
abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String orderId;
  final String date;
  CheckoutSuccess({required this.orderId, required this.date});
}

class CheckoutFailure extends CheckoutState {
  final String error;
  CheckoutFailure(this.error);
}

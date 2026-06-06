import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutInitial()) {
    on<ConfirmPaymentEvent>((event, emit) async {
      emit(CheckoutLoading());
      await Future.delayed(const Duration(seconds: 2));

      bool isSuccess = true;

      if (isSuccess) {
        String mockOrderId = "LIB-${Random().nextInt(99999)}";
        String mockDate = DateTime.now().toString().split('.')[0];

        emit(CheckoutSuccess(orderId: mockOrderId, date: mockDate));
      } else {
        emit(CheckoutFailure("فشل الاتصال بالسيرفر، حاول مجدداً"));
      }
    });
  }
}

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'payment_event.dart';
import 'payment_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutInitial()) {
    on<ConfirmPaymentEvent>((event, emit) async {
      emit(CheckoutLoading());

      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 2));

      // محاكاة النجاح
      bool isSuccess = true;

      if (isSuccess) {
        // توليد بيانات وهمية - استخدمنا Random بعد استيراد dart:math
        String mockOrderId = "LIB-${Random().nextInt(99999)}";
        String mockDate = DateTime.now().toString().split('.')[0];

        emit(CheckoutSuccess(orderId: mockOrderId, date: mockDate));
      } else {
        emit(CheckoutFailure("فشل الاتصال بالسيرفر، حاول مجدداً"));
      }
    });
  }
}

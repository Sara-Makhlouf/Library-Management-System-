import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/payment_page/data/payment_mode.dart';
import 'package:library_mobile_app/feature/payment_page/data/repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    // تحديث طريقة الدفع
    on<UpdatePaymentMethodEvent>((event, emit) {
      final currentState = state;
      if (currentState is PaymentInitial) {
        emit(
          PaymentInitial(
            selectedPayment: event.paymentMethod,
            wantsDelivery: currentState.wantsDelivery,
          ),
        );
      }
    });

    // تحديث خيار التوصيل
    on<UpdateDeliveryEvent>((event, emit) {
      final currentState = state;
      if (currentState is PaymentInitial) {
        emit(
          PaymentInitial(
            selectedPayment: currentState.selectedPayment,
            wantsDelivery: event.wantsDelivery,
          ),
        );
      }
    });

    // تأكيد وإرسال الطلب للباك إند
    on<ConfirmPaymentEvent>((event, emit) async {
      emit(PaymentLoading());
      try {
        final currentState = state;
        String paymentMethod = 'cash';
        bool wantsDelivery = true;

        if (currentState is PaymentInitial) {
          paymentMethod = currentState.selectedPayment;
          wantsDelivery = currentState.wantsDelivery;
        }

        PaymentModel paymentModel = PaymentModel(
          name: event.name,
          phone: event.phone,
          address: event.address,
          paymentMethod: paymentMethod,
          wantsDelivery: wantsDelivery,
        );

        final response = await paymentRepository.submitCheckout(paymentModel);
        emit(PaymentSuccess(response));
      } catch (e) {
        emit(PaymentFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/payment_page/data/payment_mode.dart';
import 'package:library_mobile_app/feature/payment_page/data/repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  String _selectedPayment = 'cash';
  bool _wantsDelivery = true;

  String get selectedPayment => _selectedPayment;
  bool get wantsDelivery => _wantsDelivery;

  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    on<UpdatePaymentMethodEvent>((event, emit) {
      _selectedPayment = event.paymentMethod;
      emit(
        PaymentInitial(
          selectedPayment: _selectedPayment,
          wantsDelivery: _wantsDelivery,
        ),
      );
    });

    on<UpdateDeliveryEvent>((event, emit) {
      _wantsDelivery = event.wantsDelivery;
      emit(
        PaymentInitial(
          selectedPayment: _selectedPayment,
          wantsDelivery: _wantsDelivery,
        ),
      );
    });

    on<ConfirmPaymentEvent>((event, emit) async {
      emit(PaymentLoading());
      try {
        PaymentModel paymentModel = PaymentModel(
          phoneNumber: event.phoneNumber,
          deliveryAddress: event.deliveryAddress,
          paymentMethod: _selectedPayment,
          wantsDelivery: _wantsDelivery,
          items: event.items,
        );

        final response = await paymentRepository.submitCheckout(paymentModel);
        emit(PaymentSuccess(response));
      } catch (e) {
        emit(PaymentFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

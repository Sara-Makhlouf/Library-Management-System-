import 'package:library_mobile_app/feature/payment_page/data/payment_mode.dart';

abstract class PaymentEvent {}

class UpdatePaymentMethodEvent extends PaymentEvent {
  final String paymentMethod;
  UpdatePaymentMethodEvent(this.paymentMethod);
}

class UpdateDeliveryEvent extends PaymentEvent {
  final bool wantsDelivery;
  UpdateDeliveryEvent(this.wantsDelivery);
}

class ConfirmPaymentEvent extends PaymentEvent {
  final String phoneNumber;
  final String deliveryAddress;
  final List<CheckoutItemModel> items;

  ConfirmPaymentEvent({
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.items,
  });
}

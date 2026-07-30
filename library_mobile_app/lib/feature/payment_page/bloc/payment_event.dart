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
  final String name;
  final String phone;
  final String address;

  ConfirmPaymentEvent({
    required this.name,
    required this.phone,
    required this.address,
  });
}

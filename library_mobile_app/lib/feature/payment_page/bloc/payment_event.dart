abstract class CheckoutEvent {}

class ConfirmPaymentEvent extends CheckoutEvent {
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;
  final bool wantsDelivery;

  ConfirmPaymentEvent({
    required this.name,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.wantsDelivery,
  });
}

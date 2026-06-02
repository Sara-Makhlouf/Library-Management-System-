import 'payment_mode.dart';

class OrderRequest {
  final String fullName;
  final String phone;
  final String address;
  final PaymentMode mode;
  final String? paymentMethod;

  OrderRequest({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.mode,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'type': mode == PaymentMode.buy ? 'purchase' : 'borrow',
      'payment_method': paymentMethod,
    };
  }
}

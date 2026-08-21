class OrderRequest {
  final String fullName;
  final String phone;
  final String address;
  final String paymentMethod;
  final bool wantsDelivery;

  OrderRequest({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.wantsDelivery,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'payment_method': paymentMethod,
      'wants_delivery': wantsDelivery,
      'order_type': 'combined',
    };
  }
}

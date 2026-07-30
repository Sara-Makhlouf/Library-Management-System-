class PaymentModel {
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;
  final bool wantsDelivery;

  PaymentModel({
    required this.name,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.wantsDelivery,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'payment_method': paymentMethod, // 'cash' أو 'online'
      'is_delivery': wantsDelivery, // true أو false
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      paymentMethod: json['payment_method'] ?? 'cash',
      wantsDelivery: json['is_delivery'] ?? true,
    );
  }
}

class CheckoutItemModel {
  final int bookId;
  final int quantity;

  CheckoutItemModel({required this.bookId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'book_id': bookId, 'quantity': quantity};
  }

  factory CheckoutItemModel.fromJson(Map<String, dynamic> json) {
    return CheckoutItemModel(
      bookId: json['book_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }
}

class PaymentModel {
  final String phoneNumber;
  final String deliveryAddress;
  final String paymentMethod;
  final bool wantsDelivery;
  final List<CheckoutItemModel> items;

  PaymentModel({
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.wantsDelivery,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
      'is_delivery': wantsDelivery,
      'delivery_address': deliveryAddress,
      'phone_number': phoneNumber,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

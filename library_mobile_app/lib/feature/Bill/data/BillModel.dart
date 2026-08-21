class BillModel {
  final int id;
  final String totalPrice;
  final String paymentMethod;
  final bool isDelivery;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String createdAt;
  final String status;
  final String? discountAmount;
  final String deliveryFee;
  final List<BillItemModel> items;

  BillModel({
    required this.id,
    required this.totalPrice,
    required this.paymentMethod,
    required this.isDelivery,
    this.deliveryAddress,
    this.phoneNumber,
    required this.createdAt,
    required this.status,
    required this.discountAmount,
    required this.deliveryFee,
    required this.items,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json.containsKey('data')
        ? json['data']
        : json;

    var itemsList = data['items'] ?? data['details'] ?? [];
    List<BillItemModel> parsedItems = (itemsList as List)
        .map((item) => BillItemModel.fromJson(item))
        .toList();

    return BillModel(
      id: data['id'] ?? data['bill_id'] ?? 0,
      totalPrice: (data['total_price'] ?? data['total_amount'] ?? '0')
          .toString(),
      paymentMethod: data['payment_method'] ?? 'cash',
      isDelivery: data['is_delivery'] == 1 || data['is_delivery'] == true,
      deliveryAddress: data['delivery_address'],
      phoneNumber: data['phone_number'],
      createdAt: data['created_at'] ?? '',
      status: data['status'] ?? 'unknown',
      discountAmount: data['discount_amount']?.toString(),
      deliveryFee: (data['delivery_fee'] ?? '0.00').toString(),
      items: parsedItems,
    );
  }
}

class BillItemModel {
  final int id;
  final String bookTitle;
  final String bookCover;
  final int quantity;
  final String price;
  final String type;

  BillItemModel({
    required this.id,
    required this.bookTitle,
    required this.bookCover,
    required this.quantity,
    required this.price,
    required this.type,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'] ?? json['detail_id'] ?? 0,
      bookTitle: json['book_title'] ?? json['book']?['title'] ?? 'Book Item',
      bookCover: json['book_cover'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? json['unit_price'] ?? '0').toString(),
      type: json['type'] ?? 'buy',
    );
  }
}

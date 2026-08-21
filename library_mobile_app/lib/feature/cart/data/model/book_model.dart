import 'package:library_mobile_app/feature/homepage/data/model.dart';

class CartModel {
  final int id;
  final int customerId;
  final String totalPrice;
  final List<CartItemModel> details;

  CartModel({
    required this.id,
    required this.customerId,
    required this.totalPrice,
    required this.details,
  });
  CartModel copyWith({
    int? id,
    int? customerId,
    String? totalPrice,
    List<CartItemModel>? details,
  }) {
    return CartModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      totalPrice: totalPrice ?? this.totalPrice,
      details: details ?? this.details,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];
    List<CartItemModel> parsedDetails = detailsList
        .map((item) => CartItemModel.fromJson(item))
        .toList();

    return CartModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      totalPrice: json['total_price']?.toString() ?? '0.00',
      details: parsedDetails,
    );
  }
}

class CartItemModel {
  final int id;
  final int cartId;
  final int bookId;
  final String price;
  final String type;
  final String? dueAt;
  final BookModel? book; // استخدام BookModel الأساسي مباشرة هنا!

  CartItemModel({
    required this.id,
    required this.cartId,
    required this.bookId,
    required this.price,
    required this.type,
    this.dueAt,
    this.book,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      cartId: json['cart_id'] ?? 0,
      bookId: json['book_id'] ?? 0,
      price: json['price']?.toString() ?? '0.00',
      type: json['type'] ?? '',
      dueAt: json['due_at'],
      // هنا يتم استدعاء BookModel الأساسي الذي يعالج رابط الصورة تلقائياً
      book: json['book'] != null ? BookModel.fromJson(json['book']) : null,
    );
  }
}

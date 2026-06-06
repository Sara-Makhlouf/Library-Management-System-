class CartBookModel {
  final String id;
  final String title;
  final String author;
  final double price;
  final String imageUrl;
  final bool isBorrow; // الحقل الجديد للتمييز
  int quantity; // نحتاجها في السلة لتعديل الكمية

  CartBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    this.isBorrow = false, // القيمة الافتراضية شراء
    this.quantity = 1,
  });

  // تحويل من JSON (قادم من API أو قاعدة بيانات)
  factory CartBookModel.fromJson(Map<String, dynamic> json) {
    return CartBookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
      isBorrow: json['is_borrow'] ?? false,
      quantity: json['quantity'] ?? 1,
    );
  }

  // تحويل إلى JSON (لإرسال الطلب للسيرفر)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'image_url': imageUrl,
      'is_borrow': isBorrow,
      'quantity': quantity,
    };
  }

  // ميثود لزيادة الكمية (اختياري، يساعد في الـ BLoC)
  CartBookModel copyWith({int? quantity}) {
    return CartBookModel(
      id: this.id,
      title: this.title,
      author: this.author,
      price: this.price,
      imageUrl: this.imageUrl,
      isBorrow: isBorrow ?? this.isBorrow,
      quantity: quantity ?? this.quantity,
    );
  }
}

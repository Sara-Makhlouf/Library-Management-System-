class WaitingListItem {
  final int id;
  final int customerId;
  final int bookId;
  final String createdAt;
  final WaitingListBook book;

  WaitingListItem({
    required this.id,
    required this.customerId,
    required this.bookId,
    required this.createdAt,
    required this.book,
  });

  factory WaitingListItem.fromJson(Map<String, dynamic> json) {
    return WaitingListItem(
      id: json['id'],
      customerId: json['customer_id'],
      bookId: json['book_id'],
      createdAt: json['created_at']?.toString() ?? '',
      book: WaitingListBook.fromJson(json['book']),
    );
  }
}

class WaitingListBook {
  final int id;
  final String title;
  final String? cover;
  final int stock;

  WaitingListBook({
    required this.id,
    required this.title,
    this.cover,
    required this.stock,
  });

  factory WaitingListBook.fromJson(Map<String, dynamic> json) {
    return WaitingListBook(
      id: json['id'],
      title: json['title'] ?? '',
      cover: json['cover'],
      stock: json['stock'] ?? 0,
    );
  }
}

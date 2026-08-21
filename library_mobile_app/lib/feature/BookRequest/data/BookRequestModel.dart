class BookRequestModel {
  final int id;
  final String bookTitle;
  final String authorName;
  final String status;
  final String? notes;
  final String? adminNote;
  final int? customerId;
  final String? createdAt;

  BookRequestModel({
    required this.id,
    required this.bookTitle,
    required this.authorName,
    required this.status,
    this.notes,
    this.adminNote,
    this.customerId,
    this.createdAt,
  });

  factory BookRequestModel.fromJson(Map<String, dynamic> json) {
    return BookRequestModel(
      id: json['id'] ?? 0,
      bookTitle: json['book_title'] ?? '',
      authorName: json['author_name'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      adminNote: json['admin_note'],
      customerId: json['customer_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'book_title': bookTitle, 'author_name': authorName, 'notes': notes};
  }
}

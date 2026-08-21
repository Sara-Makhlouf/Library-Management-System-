import 'package:library_mobile_app/core/constants.dart';

class BookDetailsModel {
  final int id;
  final String title;
  final String? isbn;
  final String? price;
  final String? salePrice;
  final String? cover;
  final int? totalPages;
  final int? borrowDuration;
  final int? totalCopies;
  final int? stock;
  final String? authorshipDate;
  final int? categoryId;
  final String? filePath;
  final bool isDigital;
  final String? avgRating;
  final int totalReviews;
  final bool isAvailable;
  final bool isWaitingLocally;
  final List<Map<String, dynamic>> translations;
  final List<Map<String, dynamic>> authors;
  final Map<String, dynamic>? category;

  BookDetailsModel({
    required this.id,
    required this.title,
    this.isbn,
    this.price,
    this.salePrice,
    this.cover,
    this.totalPages,
    this.borrowDuration,
    this.totalCopies,
    this.stock,
    this.authorshipDate,
    this.categoryId,
    this.filePath,
    required this.isDigital,
    this.avgRating,
    required this.totalReviews,
    required this.isAvailable,
    this.isWaitingLocally = false,
    required this.translations,
    required this.authors,
    this.category,
  });

  // 🔹 أضيفي هذه الدالة (copyWith) هنا 👇
  BookDetailsModel copyWith({
    int? id,
    String? title,
    String? isbn,
    String? price,
    String? salePrice,
    String? cover,
    int? totalPages,
    int? borrowDuration,
    int? totalCopies,
    int? stock,
    String? authorshipDate,
    int? categoryId,
    String? filePath,
    bool? isDigital,
    String? avgRating,
    int? totalReviews,
    bool? isAvailable,
    bool? isWaitingLocally,
    List<Map<String, dynamic>>? translations,
    List<Map<String, dynamic>>? authors,
    Map<String, dynamic>? category,
  }) {
    return BookDetailsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isbn: isbn ?? this.isbn,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      cover: cover ?? this.cover,
      totalPages: totalPages ?? this.totalPages,
      borrowDuration: borrowDuration ?? this.borrowDuration,
      totalCopies: totalCopies ?? this.totalCopies,
      stock: stock ?? this.stock,
      authorshipDate: authorshipDate ?? this.authorshipDate,
      categoryId: categoryId ?? this.categoryId,
      filePath: filePath ?? this.filePath,
      isDigital: isDigital ?? this.isDigital,
      avgRating: avgRating ?? this.avgRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isAvailable: isAvailable ?? this.isAvailable,
      isWaitingLocally: isWaitingLocally ?? this.isWaitingLocally,
      translations: translations ?? this.translations,
      authors: authors ?? this.authors,
      category: category ?? this.category,
    );
  }

  factory BookDetailsModel.fromJson(Map<String, dynamic> json) {
    String? coverPath = json['cover'] as String?;
    if (coverPath != null && coverPath.isNotEmpty) {
      if (!coverPath.startsWith('http')) {
        coverPath = '${imageBaseUrl}storage/$coverPath';
      }
    }

    return BookDetailsModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'بدون عنوان',
      isbn: json['ISBN'] as String?,
      price: json['price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      cover: coverPath,
      totalPages: json['total_pages'] as int?,
      borrowDuration: json['borrow_duration'] as int?,
      totalCopies: json['total_copies'] as int?,
      stock: json['stock'] as int?,
      authorshipDate: json['authorship_date'] as String?,
      categoryId: json['category_id'] as int?,
      filePath: json['file_path'] as String?,
      isDigital: json['is_digital'] as bool? ?? false,
      avgRating: json['avg_rating']?.toString(),
      totalReviews: json['total_reviews'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
      translations: List<Map<String, dynamic>>.from(json['translations'] ?? []),
      authors: List<Map<String, dynamic>>.from(json['authors'] ?? []),
      category: json['category'] as Map<String, dynamic>?,
    );
  }
}

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
    required this.translations,
    required this.authors,
    this.category,
  });

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

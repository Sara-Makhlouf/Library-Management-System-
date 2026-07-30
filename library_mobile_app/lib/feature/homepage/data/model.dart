// library_mobile_app/feature/homepage/data/model.dart

import 'package:library_mobile_app/core/constants.dart';

class CategoryModel {
  final int id;
  final String name;
  final int booksCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.booksCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      booksCount: json['books_count'] as int? ?? 0,
    );
  }
}

class BookModel {
  final int id;
  final String title;
  final String? isbn;
  final String? price;
  final String? salePrice;
  final String? cover;
  final int? totalPages;
  final int? categoryId;
  final String? filePath;
  final int? stock;
  final String authorName;
  final String? avgRating;
  final String categoryName;
  bool isFavorite;

  BookModel({
    required this.id,
    required this.title,
    this.isbn,
    this.price,
    this.salePrice,
    this.cover,
    this.totalPages,
    this.categoryId,
    this.filePath,
    this.stock,
    required this.authorName,
    this.avgRating,
    required this.categoryName,
    this.isFavorite = false,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    print('📦 تفاصيل الـ JSON للكتاب: $json');
    String firstAuthor = 'مؤلف مجهول';

    if (json['authors'] != null &&
        json['authors'] is List &&
        (json['authors'] as List).isNotEmpty) {
      final first = json['authors'][0];
      if (first is Map) {
        firstAuthor =
            first['name'] as String? ??
            first['title'] as String? ??
            'مؤلف مجهول';
      } else if (first is String) {
        firstAuthor = first;
      }
    } else if (json['author'] != null) {
      // إذا كان السيرفر يرسل كائن مفرد للمؤلف بدلاً من مصفوفة
      if (json['author'] is Map) {
        firstAuthor = json['author']['name'] as String? ?? 'مؤلف مجهول';
      } else if (json['author'] is String) {
        firstAuthor = json['author'];
      }
    } else if (json['author_name'] != null) {
      // إذا كان السيرفر يرسل الاسم مباشرة كحقل نصي
      firstAuthor = json['author_name'].toString();
    }
    final categoryData = json['category'] as Map<String, dynamic>?;
    String category = 'عام';

    if (categoryData != null) {
      category = categoryData['name'] as String? ?? 'عام';
    }

    String? coverPath = json['cover'] as String?;
    if (coverPath != null && coverPath.isNotEmpty) {
      if (!coverPath.startsWith('http')) {
        coverPath = '${imageBaseUrl}storage/$coverPath';
      }
    }

    return BookModel(
      id: json['id'] as int,
      title:
          json['title'] as String? ?? json['name'] as String? ?? 'بدون عنوان',
      isbn: json['ISBN'] as String?,
      price: json['price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      cover:
          coverPath, // <--- سيصبح الرابط كاملاً هنا (مثال: http://192.168.1.18:8000/storage/covers/default.png)
      totalPages: json['total_pages'] as int?,
      categoryId: json['category_id'] as int?,
      filePath: json['file_path'] as String?,
      stock: json['stock'] as int?,
      authorName: firstAuthor,
      avgRating: json['avg_rating']?.toString(),
      categoryName: category,
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == true
          ? true
          : false,
    );
  }
}

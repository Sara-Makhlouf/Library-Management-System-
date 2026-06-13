// library_mobile_app/feature/homepage/data/model.dart

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
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final authorsList = json['authors'] as List?;
    String firstAuthor = 'مؤلف مجهول';

    if (authorsList != null && authorsList.isNotEmpty) {
      firstAuthor = authorsList[0]['name'] as String? ?? 'مؤلف مجهول';
    }
    final categoryData = json['category'] as Map<String, dynamic>?;
    String category = 'عام';

    if (categoryData != null) {
      category = categoryData['name'] as String? ?? 'عام';
    }

    return BookModel(
      id: json['id'] as int,
      title:
          json['title'] as String? ?? json['name'] as String? ?? 'بدون عنوان',
      isbn: json['ISBN'] as String?,
      price: json['price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      cover: json['cover'] as String?,
      totalPages: json['total_pages'] as int?,
      categoryId: json['category_id'] as int?,
      filePath: json['file_path'] as String?,
      stock: json['stock'] as int?,
      authorName: firstAuthor,
      avgRating: json['avg_rating']?.toString(),
      categoryName: category,
    );
  }
}

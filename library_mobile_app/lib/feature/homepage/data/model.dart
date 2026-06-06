class BookModel {
  final String title;
  final String author;
  final int publishYear;

  BookModel({
    required this.title,
    required this.author,
    required this.publishYear,
  });
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      title: json['title'] ?? 'عنوان غير معروف',
      author: json['author'] ?? 'كاتب غير معروف',
      publishYear: json['publish_year'] ?? 0,
    );
  }
}

import 'package:library_mobile_app/core/network.dart';
import 'package:library_mobile_app/feature/books/data/bookDetailsModel.dart';

class BookRepository {
  Future<BookDetailsModel> getBookDetails(String bookId) async {
    try {
      final dio = await NetworkService.getInstance();
      final response = await dio.get('/books/$bookId');
      return BookDetailsModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load book details: $e');
    }
  }
}

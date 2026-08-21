import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';
import 'package:library_mobile_app/feature/BookRequest/data/BookRequestModel.dart';

class BookRequestRepository {
  Future<List<BookRequestModel>> getMyBookRequests() async {
    try {
      final Dio dio = await NetworkService.getInstance();

      final response = await dio.get('/my-book-requests');
      final data = response.data['data'] as List;
      return data.map((json) => BookRequestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب طلبات الكتب: $e');
    }
  }

  Future<BookRequestModel> submitBookRequest({
    required String bookTitle,
    required String authorName,
    required String notes,
  }) async {
    try {
      final Dio dio = await NetworkService.getInstance();

      final response = await dio.post(
        '/my-book-requests',
        data: {
          'book_title': bookTitle,
          'author_name': authorName,
          'notes': notes,
        },
      );
      return BookRequestModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('فشل في إرسال طلب الكتاب: $e');
    }
  }

  Future<BookRequestModel> showBookRequest(int id) async {
    try {
      final Dio dio = await NetworkService.getInstance();

      final response = await dio.get('/my-book-requests/$id');
      return BookRequestModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الطلب: $e');
    }
  }

  Future<void> cancelBookRequest(int id) async {
    try {
      final Dio dio = await NetworkService.getInstance();

      await dio.delete('/my-book-requests/$id');
    } catch (e) {
      throw Exception('فشل في إلغاء الطلب: $e');
    }
  }
}

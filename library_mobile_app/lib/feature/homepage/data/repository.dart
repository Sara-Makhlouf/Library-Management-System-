import 'package:dio/dio.dart';
import 'model.dart';

class HomeRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.18:8000/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _dio.get('categories/list');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          final List<dynamic> categoriesJson = responseData['data'];
          return categoriesJson
              .map((json) => CategoryModel.fromJson(json))
              .toList();
        }
      }
      throw Exception('فشل جلب الفئات من السيرفر');
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب الفئات: $e');
    }
  }

  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final response = await _dio.get(
        'books',
        queryParameters: {'search': query},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> booksJson =
              responseData['data']['data'] as List<dynamic>;
          return booksJson.map((json) => BookModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('حدث خطأ أثناء البحث: $e');
    }
  }

  Future<List<BookModel>> fetchBooks({int? categoryId}) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (categoryId != null) {
        queryParameters['category_id'] = categoryId;
      }
      final response = await _dio.get(
        'books',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> booksJson =
              responseData['data']['data'] as List<dynamic>;
          return booksJson.map((json) => BookModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب كتب الفئة: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';
import 'model.dart';

class HomeRepository {
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final dio = await NetworkService.getInstance();
      print(
        '🟡 fetchCategories request URL: ${dio.options.baseUrl}/admin/categories',
      );
      final response = await dio.get('/admin/categories');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success') {
          final List<dynamic> categoriesJson = responseData['data'];
          final items = categoriesJson
              .map((json) => CategoryModel.fromJson(json))
              .toList();
          print('🟡 fetchCategories response data length: ${items.length}');
          return items;
        }
      }
      throw Exception('فشل جلب الفئات من السيرفر');
    } on DioException catch (e) {
      print('🟡 fetchCategories DioException: $e');
      throw Exception('حدث خطأ أثناء جلب الفئات: $e');
    } catch (e) {
      print('🟡 fetchCategories error: $e');
      throw Exception('حدث خطأ أثناء جلب الفئات: $e');
    }
  }

  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final dio = await NetworkService.getInstance();
      print(
        '🟡 searchBooks request URL: ${dio.options.baseUrl}/books?search=$query',
      );
      final response = await dio.get(
        '/books',
        queryParameters: {'search': query},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> booksJson =
              responseData['data']['data'] as List<dynamic>;
          final items = booksJson
              .map((json) => BookModel.fromJson(json))
              .toList();
          print('🟡 searchBooks response data length: ${items.length}');
          return items;
        }
      }
      return [];
    } on DioException catch (e) {
      print('🟡 searchBooks DioException: $e');
      throw Exception('حدث خطأ أثناء البحث: $e');
    } catch (e) {
      print('🟡 searchBooks error: $e');
      throw Exception('حدث خطأ أثناء البحث: $e');
    }
  }

  Future<List<BookModel>> fetchBooks({int? categoryId}) async {
    try {
      final dio = await NetworkService.getInstance();
      print(
        '🟡 fetchBooks request URL: ${dio.options.baseUrl}/books${categoryId != null ? '?category_id=$categoryId' : ''}',
      );
      final Map<String, dynamic> queryParameters = {};
      if (categoryId != null) {
        queryParameters['category_id'] = categoryId;
      }
      final response = await dio.get(
        '/books',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> booksJson =
              responseData['data']['data'] as List<dynamic>;
          final items = booksJson
              .map((json) => BookModel.fromJson(json))
              .toList();
          print('🟡 fetchBooks response data length: ${items.length}');
          return items;
        }
      }
      return [];
    } on DioException catch (e) {
      print('🟡 fetchBooks DioException: $e');
      throw Exception('حدث خطأ أثناء جلب كتب الفئة: $e');
    } catch (e) {
      print('🟡 fetchBooks error: $e');
      throw Exception('حدث خطأ أثناء جلب كتب الفئة: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'model.dart';

class HomeRepository {
  final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    print('🟡 Dio created with baseUrl: ${dio.options.baseUrl}');
    return dio;
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final fullUrl = Uri.parse(
      _dio.options.baseUrl,
    ).resolve('categories/list').toString();
    try {
      print('🟡 fetchCategories request URL: $fullUrl');
      final response = await _dio.get('categories/list');
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
    final requestPath = 'books';
    final uri = Uri.parse(_dio.options.baseUrl).resolve(requestPath);
    final fullUrl = uri.replace(queryParameters: {'search': query}).toString();
    try {
      print('🟡 searchBooks request URL: $fullUrl');
      final response = await _dio.get(
        requestPath,
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
    final requestPath = 'books';
    final uri = Uri.parse(_dio.options.baseUrl).resolve(requestPath);
    final fullUrl = uri
        .replace(
          queryParameters: categoryId != null
              ? {'category_id': '$categoryId'}
              : {},
        )
        .toString();
    try {
      print('🟡 fetchBooks request URL: $fullUrl');
      final Map<String, dynamic> queryParameters = {};
      if (categoryId != null) {
        queryParameters['category_id'] = categoryId;
      }
      final response = await _dio.get(
        requestPath,
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

import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class HomeRepository {
  final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl/',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(tokenKey) ?? '';

          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
      ),
    );
    print('🟡 Dio created with baseUrl: ${dio.options.baseUrl}');
    return dio;
  }

  Future<List<CategoryModel>> fetchCategories() async {
    const requestPath = 'admin/categories';
    final fullUrl = Uri.parse(_dio.options.baseUrl)
        .resolve(requestPath)
        .toString();

    try {
      print('🟡 [HomeRepository] جلب الفئات - URL: $fullUrl');
      final response = await _dio.get(requestPath);

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 'success') {
          final List<dynamic> categoriesJson = responseData['data'] ?? [];
          final items = categoriesJson
              .map((json) => CategoryModel.fromJson(json))
              .toList();

          print('✅ [HomeRepository] تم جلب ${items.length} فئة بنجاح');
          return items;
        }
      }

      throw Exception('فشل جلب الفئات من السيرفر');
    } on DioException catch (e) {
      print('⚠️ [HomeRepository] DioException في fetchCategories: $e');

      if (e.response?.statusCode == 404) {
        throw Exception(
          'المسار غير موجود: لا يوجد endpoint للفئات في هذا النطاق. الرجاء التحقق من المسار /admin/categories.',
        );
      }

      if (e.response?.statusCode == 401) {
        throw Exception('غير مصرح لك بالوصول إلى الفئات. يرجى تسجيل الدخول مرة أخرى.');
      }

      if (e.response?.statusCode == 403) {
        throw Exception('ليس لديك صلاحية للوصول إلى قائمة الفئات.');
      }

      throw Exception('حدث خطأ أثناء جلب الفئات: ${e.message ?? 'يرجى المحاولة مرة أخرى'}');
    } catch (e) {
      print('❌ [HomeRepository] fetchCategories error: $e');
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

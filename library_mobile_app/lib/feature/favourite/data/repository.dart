import 'package:library_mobile_app/core/network.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';

class FavoriteRepository {
  // جلب عناصر المفضلة (GET /favorites)
  Future<List<BookModel>> getFavorites() async {
    try {
      final dio =
          await NetworkService.getInstance(); // استخدام النسخة المركزية مع التوكن والـ BaseUrl
      final response = await dio.get(
        '/favorites',
      ); // لا داعي لكتابة baseUrl مجدداً لأنه مضاف مسبقاً

      print('🟢 نجح جلب المفضلة: ${response.statusCode}');
      final List<dynamic> favoritesJson = response.data['data'] ?? [];
      return favoritesJson.map((json) => BookModel.fromJson(json)).toList();
    } catch (e) {
      print('🔴 فشل جلب المفضلة: $e');
      rethrow;
    }
  }

  // إضافة أو إزالة من المفضلة (POST /favorites/toggle)
  Future<void> toggleFavorite(int bookId) async {
    try {
      final dio = await NetworkService.getInstance(); // استخدام النسخة المركزية
      final response = await dio.post(
        '/favorites/toggle',
        data: {'book_id': bookId},
      );

      print('🟢 نجح تبديل المفضلة للكتاب ID: $bookId');
      print('📦 استجابة السيرفر: ${response.data}');
    } catch (e) {
      print('🔴 فشل تبديل المفضلة للكتاب ID: $bookId | الخطأ: $e');
      rethrow;
    }
  }
}

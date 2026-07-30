import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';

class BookCartRepository {
  Future<void> addBookToCart(String bookId, String type) async {
    try {
      final dio = await NetworkService.getInstance();
      await dio.post(
        '/cart/add',
        data: {
          'book_id': bookId,
          'type': type, // إرسال نوع الطلب (شراء أو استعارة)
        },
      );
    } catch (e) {
      throw Exception('Failed to add book to cart: $e');
    }
  }

  Future<CartModel> getCart() async {
    try {
      final dio = await NetworkService.getInstance();

      // إضافة Cache-Control لمنع الـ Dio من قراءة البيانات من الذاكرة المؤقتة وإجباره على الاتصال بالسيرفر
      final response = await dio.get(
        '/cart',
        options: Options(
          headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
        ),
      );

      final data = response.data['data'];
      return CartModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  // التعديل هنا: استقبال bookId (سواء كان String أو int حسب نوعه عندك) وإرساله للرابط مباشرة
  Future<void> removeBookFromCart(dynamic bookId) async {
    try {
      print('🛒 Attempting to remove book with ID: $bookId');

      final dio = await NetworkService.getInstance();
      // إرسال الـ bookId في الـ URL تماماً كما يطلبه الباك إيند لديك
      final response = await dio.delete('/cart/remove/$bookId');

      print('🛒 Delete response status code: ${response.statusCode}');
      print('🛒 Delete response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to remove book from cart');
      }

      print('✅ Book removed successfully from cart!');
    } catch (e) {
      print('❌ Error in removeBookFromCart: $e');
      throw Exception(e.toString());
    }
  }
}

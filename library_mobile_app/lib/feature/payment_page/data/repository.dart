import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';
import 'package:library_mobile_app/feature/payment_page/data/payment_mode.dart';

class PaymentRepository {
  Future<Map<String, dynamic>> submitCheckout(PaymentModel paymentModel) async {
    try {
      final Dio dio = await NetworkService.getInstance();

      print(
        '📦 [PaymentRepository] Sending checkout data: ${paymentModel.toJson()}',
      );

      final response = await dio.post(
        'cart/checkout',
        data: paymentModel.toJson(),
      );

      print(
        '📥 [PaymentRepository] Response Status Code: ${response.statusCode}',
      );
      print('📥 [PaymentRepository] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('فشل إتمام الطلب من الخادم');
      }
    } on DioException catch (e) {
      print('❌ [PaymentRepository] DioException error: ${e.error}');
      print('❌ [PaymentRepository] DioException response: ${e.response?.data}');
      throw Exception(e.error ?? 'حدث خطأ في الاتصال بالخادم');
    } catch (e) {
      print('❌ [PaymentRepository] Unexpected error: $e');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart'; // تأكدي أن هذا هو مسار ملف NetworkService

class WaitingListRepository {
  Future<Response> getMyWaitingList() async {
    try {
      final dio = await NetworkService.getInstance();
      final response = await dio.get('/my-waiting-list');
      return response;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'حدث خطأ غير متوقع')
          : 'حدث خطأ في الاتصال بالسيرفر';
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  Future<Response> joinWaitingList(int bookId) async {
    try {
      final dio = await NetworkService.getInstance();
      final response = await dio.post('/books/$bookId/waiting-list/join');
      return response;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'حدث خطأ غير متوقع')
          : 'حدث خطأ في الاتصال بالسيرفر';
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  Future<Response> leaveWaitingList(int bookId) async {
    try {
      final dio = await NetworkService.getInstance();
      final response = await dio.delete('/books/$bookId/waiting-list/leave');
      return response;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'حدث خطأ غير متوقع')
          : 'حدث خطأ في الاتصال بالسيرفر';
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }
}

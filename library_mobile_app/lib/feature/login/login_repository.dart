import '../../core/network.dart';
import 'package:dio/dio.dart';

class LoginRepository {
  Future<Map<String, dynamic>> login(String phone, String password, String fcmToken) async {
    final dio = await NetworkService.getInstance();
    try {
      final response = await dio.post('/login', data: {
        'phone': phone,
        'password': password,
        'fcm_token': fcmToken,
      });
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data['message'] 
          ?? e.response?.data['error']
          ?? 'Invalid phone number or password';
      throw Exception(message);
    }
  }
}

import '../../core/network.dart';
import 'package:dio/dio.dart';

class LoginRepository {
  Future<Map<String, dynamic>> login(String phone, String password, String fcmToken) async {
    final dio = await NetworkService.getInstance();
    print('🔵 Dio instance ready, baseUrl: ${dio.options.baseUrl}');
    try {
      print('🔵 Sending login request with phone: $phone');
      final response = await dio.post('/login', data: {
        'phone': phone,
        'password': password,
        'fcm_token': fcmToken,
      });
      print('🟢 Response received: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('🔴 DioException type: ${e.type}');
      print('🔴 DioException message: ${e.message}');
      print('🔴 Response data: ${e.response?.data}');
      final message = e.response?.data['message'] 
          ?? e.response?.data['error']
          ?? 'Invalid phone number or password';
      throw Exception(message);
    }
  }
}

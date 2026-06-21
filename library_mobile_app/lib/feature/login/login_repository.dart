import '../../core/network.dart';
import 'package:dio/dio.dart';

class LoginRepository {
  Future<Map<String, dynamic>> login(String phone, String password, String fcmToken) async {
    final dio = await NetworkService.getInstance();
    final baseUrl = dio.options.baseUrl;
    final requestPath = '/login';
    final requestUrl = Uri.parse(baseUrl).resolve(requestPath).toString();
    final requestBody = {
      'phone': phone,
      'password': password,
      'fcm_token': fcmToken,
    };

    print('🔵 Base URL: $baseUrl');
    print('🔵 Request URL: $requestUrl');
    print('🔵 Request body: $requestBody');

    try {
      final response = await dio.post(requestPath, data: requestBody);
      print('🟢 Response status code: ${response.statusCode}');
      print('🟢 Response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('🔴 DioException type: ${e.type}');
      print('🔴 DioException message: ${e.message}');
      print('🔴 Failed request URL: $requestUrl');
      print('🔴 Response status code: ${e.response?.statusCode}');
      print('🔴 Response data: ${e.response?.data}');
      final message = e.response?.data['message']
          ?? e.response?.data['error']
          ?? 'Invalid phone number or password';
      throw Exception(message);
    }
  }
}

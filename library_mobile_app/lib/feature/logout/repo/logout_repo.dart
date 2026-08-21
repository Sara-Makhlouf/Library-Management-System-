import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network.dart';

class LogoutRepository {
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final dio = await NetworkService.getInstance();
    final baseUrl = dio.options.baseUrl;
    final requestPath = '/logout';
    final requestUrl = Uri.parse(baseUrl).resolve(requestPath).toString();

    print('🔵 Base URL: $baseUrl');
    print('🔵 Request URL: $requestUrl');

    try {
      if (token != null && token.isNotEmpty) {
        final response = await dio.post(
          requestPath,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        );
        print('🟢 Response status code: ${response.statusCode}');
        print('🟢 Response data: ${response.data}');
      }
    } on DioException {
    } finally {
      await prefs.remove('auth_token');
      await prefs.remove('fcm_token');
    }
  }
}

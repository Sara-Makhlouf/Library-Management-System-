import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';

class RegisterRepository {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String gender,
    required String phone,
    required String dob,
    String? lang,
    String? fcmToken,
  }) async {
    final dio = await NetworkService.getInstance();

    print('🔵 Sending register request with phone: $phone, email: $email');

    try {
      final response = await dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'gender': gender,
          'phone': phone,
          'DOB': dob,
          if (lang != null) 'lang': lang,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );
      print('🟢 Register response status: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('🔴 DioException type: ${e.type}');
      print('🔴 DioException message: ${e.message}');
      print('🔴 Response data: ${e.response?.data}');
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';

class RegisterRepository {
  Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    final dio = await NetworkService.getInstance();

    try {
      final response = await dio.post('/send-otp', data: {'phone': phone});

      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        if (data['message'] != null) {
          throw Exception(data['message'].toString());
        }

        if (data['errors'] != null) {
          throw Exception(data['errors'].toString());
        }
      }

      throw Exception(e.message ?? 'Failed to send verification code');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final dio = await NetworkService.getInstance();

    try {
      final response = await dio.post(
        '/verify-otp',
        data: {'phone': phone, 'otp': otp},
      );

      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        if (data['message'] != null) {
          throw Exception(data['message'].toString());
        }

        if (data['errors'] != null) {
          throw Exception(data['errors'].toString());
        }
      }

      throw Exception(e.message ?? 'OTP verification failed');
    } catch (e) {
      rethrow;
    }
  }

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

          if (lang != null && lang.isNotEmpty) 'lang': lang,

          if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        if (data['message'] != null) {
          throw Exception(data['message'].toString());
        }

        if (data['errors'] != null) {
          throw Exception(data['errors'].toString());
        }
      }

      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      rethrow;
    }
  }
}

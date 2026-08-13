import 'dart:convert';

import 'package:http/http.dart' as http;

class ForgotPasswordRepository {
  final String baseUrl;

  ForgotPasswordRepository({required this.baseUrl});

  Future<String> sendOtp({required String phone}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data['message'] ?? 'Verification code sent successfully';
      }

      throw Exception(data['message'] ?? 'Failed to send verification code');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> verifyOtp({required String phone, required String otp}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-otp'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final resetToken = data['reset_token'];

        if (resetToken == null) {
          throw Exception('Reset token was not returned by server');
        }

        return resetToken.toString();
      }

      throw Exception(data['message'] ?? 'Invalid verification code');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> resetPassword({
    required String phone,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data['message'] ?? 'Password reset successfully';
      }

      throw Exception(data['message'] ?? 'Failed to reset password');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

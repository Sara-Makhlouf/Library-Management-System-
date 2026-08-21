import 'dart:convert';

import 'package:http/http.dart' as http;

class ForgotPasswordRepository {
  final String baseUrl;

  ForgotPasswordRepository({required this.baseUrl});

  /// إرسال OTP إلى البريد الإلكتروني
  Future<String> sendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
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

  /// إعادة تعيين كلمة المرور
  ///
  /// Laravel سيتحقق من:
  /// email
  /// otp_code
  /// password
  /// password_confirmation
  Future<String> resetPassword({
    required String email,
    required String otp,
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
          'email': email,
          'otp_code': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data['message'] ?? 'Password reset successfully';
      }

      // Laravel validation errors
      if (data['errors'] != null) {
        final errors = data['errors'] as Map;

        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
      }

      throw Exception(data['message'] ?? 'Failed to reset password');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

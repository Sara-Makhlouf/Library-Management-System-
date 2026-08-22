import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:library_mobile_app/core/constants.dart';

class RegisterRepository {
  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    print('================ OTP REQUEST ================');
    print('EMAIL: $email');
    print('URL: $baseUrl/send-otp');

    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');
    print('============================================');

    final body = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw Exception(
      body['message']?.toString() ?? 'Failed to send verification code',
    );
  }

  Future<Map<String, dynamic>> register({
    required Map<String, dynamic> registerData,
  }) async {
    final data = Map<String, dynamic>.from(registerData);
    // keep register data as provided (email-based OTP flow)

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    final body = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 422) {
      final errors = body['errors'];

      if (errors is Map) {
        final messages = <String>[];

        errors.forEach((key, value) {
          if (value is List) {
            messages.addAll(value.map((e) => e.toString()));
          } else {
            messages.add(value.toString());
          }
        });

        throw Exception(
          messages.isNotEmpty
              ? messages.join('\n')
              : body['message']?.toString() ?? 'Validation failed',
        );
      }
    }

    throw Exception(body['message']?.toString() ?? 'Registration failed');
  }

  String _normalizePhone(String phone) {
    phone = phone.trim();

    phone = phone
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    if (phone.startsWith('+963')) {
      return '0${phone.substring(4)}';
    }

    if (phone.startsWith('00963')) {
      return '0${phone.substring(5)}';
    }

    if (phone.startsWith('963')) {
      return '0${phone.substring(3)}';
    }

    return phone;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {'message': response.body};
    } catch (_) {
      return {
        'message': response.body.isNotEmpty
            ? response.body
            : 'Unknown server error',
      };
    }
  }
}

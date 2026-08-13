import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:library_mobile_app/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountRepository {
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/delete-account'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = 'Failed to delete account';

    try {
      final data = jsonDecode(response.body);

      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}

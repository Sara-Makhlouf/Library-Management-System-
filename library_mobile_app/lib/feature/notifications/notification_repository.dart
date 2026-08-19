import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_model.dart';

class NotificationRepository {
  NotificationRepository({Dio? dio}) : _dio = dio ?? Dio(_buildDioOptions());

  final Dio _dio;

  static BaseOptions _buildDioOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey) ?? '';

    try {
      final response = await _dio.get(
        '/notifications',
        options: token.isEmpty
            ? null
            : Options(
                headers: {
                  'Authorization': 'Bearer $token',
                },
              ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load notifications');
      }

      final data = response.data;
      List<dynamic> items = [];

      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          items = data['data'] as List;
        } else if (data['notifications'] is List) {
          items = data['notifications'] as List;
        }
      }

      return items
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message']?.toString() ?? e.message ?? 'Error loading notifications');
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }
}

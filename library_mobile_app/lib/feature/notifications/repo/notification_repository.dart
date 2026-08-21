import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/notification_model.dart';

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

  // =========================================================
  // GET NOTIFICATIONS
  // =========================================================

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(tokenKey) ?? '';

    print('🔑 NOTIFICATION TOKEN: $token');

    try {
      final response = await _dio.get(
        '/notifications',
        options: token.isEmpty
            ? null
            : Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(
        '🔔 NOTIFICATIONS RESPONSE: '
        '${response.statusCode} -> ${response.data}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load notifications');
      }

      final data = response.data;

      List<dynamic> items = [];

      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['data'];

        // {success: true, data: [...]}
        if (inner is List) {
          items = inner;
        }
        // Laravel pagination
        // {success: true, data: {data: [...]}}
        else if (inner is Map<String, dynamic> && inner['data'] is List) {
          items = inner['data'] as List;
        }
        // {notifications: [...]}
        else if (data['notifications'] is List) {
          items = data['notifications'] as List;
        }
      }

      print('📦 NOTIFICATIONS COUNT: ${items.length}');

      return items
          .map(
            (json) =>
                NotificationModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } on DioException catch (e) {
      final respData = e.response?.data;

      String message;

      if (respData is Map && respData['message'] != null) {
        message = respData['message'].toString();
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      } else {
        message = 'Error loading notifications';
      }

      throw Exception(message);
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  // =========================================================
  // GET UNREAD COUNT
  // =========================================================

  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(tokenKey) ?? '';

    try {
      final response = await _dio.get(
        '/notifications/unread-count',
        options: token.isEmpty
            ? null
            : Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(
        '🔴 UNREAD COUNT RESPONSE: '
        '${response.statusCode} -> ${response.data}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get unread count');
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final count = data['data'];

        if (count is int) {
          return count;
        }

        return int.tryParse(count.toString()) ?? 0;
      }

      return 0;
    } on DioException catch (e) {
      print('❌ UNREAD COUNT ERROR: ${e.response?.data}');

      throw Exception(
        e.response?.data?['message'] ??
            'Error getting unread notifications count',
      );
    }
  }

  // =========================================================
  // MARK ONE AS READ
  // =========================================================

  Future<void> markAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(tokenKey) ?? '';

    await _dio.put(
      '/notifications/$id/read',
      options: token.isEmpty
          ? null
          : Options(headers: {'Authorization': 'Bearer $token'}),
    );

    print('✅ Notification $id marked as read');
  }

  // =========================================================
  // MARK ALL AS READ
  // =========================================================

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(tokenKey) ?? '';

    final response = await _dio.put(
      '/notifications/mark-all-as-read',
      options: token.isEmpty
          ? null
          : Options(headers: {'Authorization': 'Bearer $token'}),
    );

    print(
      '✅ MARK ALL AS READ: '
      '${response.statusCode} -> ${response.data}',
    );
  }
}

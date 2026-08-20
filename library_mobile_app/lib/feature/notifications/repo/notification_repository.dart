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

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey) ?? '';
    print('TOKEN: $token'); // <-- ضيف هاد

    try {
      final response = await _dio.get(
        '/notifications',
        options: token.isEmpty
            ? null
            : Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(
        'NOTIFICATIONS RESPONSE: ${response.statusCode} -> ${response.data}',
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

        if (inner is List) {
          items = inner;
        } else if (inner is Map<String, dynamic> && inner['data'] is List) {
          // حالة Laravel pagination: { success, data: { data: [...] } }
          print('STATUS: ${response.statusCode}');
          print('🪜🪜🪜🪜🪜🪜RAW DATA: ${response.data}');
          print('✔️✔️✔️✔️✔️ITEMS COUNT: ${items.length}');
          items = inner['data'] as List;
        } else if (data['notifications'] is List) {
          items = data['notifications'] as List;
        }
      }

      return items
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      // Try to extract server-provided message when available
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
}

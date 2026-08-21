/*import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkService {
  static Dio? _instance;

  static Future<Dio> getInstance() async {
    if (_instance != null && _instance!.options.baseUrl.isNotEmpty) {
      return _instance!;
    }

    print('🌐 جاري إنشاء اتصال Dio بالرابط: $baseUrl');

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(requestBody: true, responseBody: true),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    _instance = dio;
    return _instance!;
  }
}*/
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:library_mobile_app/core/constants.dart';

class NetworkService {
  static Dio? _instance;

  static Future<Dio> getInstance() async {
    // إذا كانت النسخة موجودة مسبقاً ولكن الـ baseUrl لها فارغ، نقوم بإعادة إنشائها!
    if (_instance != null && _instance!.options.baseUrl.isNotEmpty) {
      return _instance!;
    }

    print('🌐 جاري إنشاء اتصال Dio بالرابط: $baseUrl');

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1. إضافة الـ PrettyDioLogger (للتنسيق والطباعة)
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // 2. إضافة الـ Interceptor الخاص بالـ Auth (للمنطق والعمليات)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    _instance = dio;
    return _instance!;
  }
}

import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkService {
  static Dio? _instance;

  static Future<Dio> getInstance() async {
    if (_instance != null) return _instance!;

   final dio = Dio(BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 8),
  receiveTimeout: const Duration(seconds: 8),
  headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    print('🌐 Dio created with resolved baseUrl: ${dio.options.baseUrl}');

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requestUrl = options.uri.toString();
          print('🌐 Outgoing request: ${options.method} $requestUrl');
          print('🌐 Request headers before auth attach: ${options.headers}');

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🌐 Authorization token found and attached to request headers');
          } else {
            print('🌐 Warning: no authorization token found; request is going out without authentication');
          }

          print('🌐 Request headers after auth attach: ${options.headers}');
          return handler.next(options);
        },
        onError: (e, handler) {
          print('❌ Request failed: ${e.requestOptions.method} ${e.requestOptions.uri}');
          print('❌ Error type: ${e.type}');
          print('❌ Error message: ${e.message}');
          print('❌ Response status code: ${e.response?.statusCode}');

          final message = e.response?.data['message'];
          if (message != null) {
            throw DioException(
              requestOptions: e.requestOptions,
              error: message,
            );
          }
          return handler.next(e);
        },
        onResponse: (response, handler) {
          print('✅ Response status code: ${response.statusCode}');
          return handler.next(response);
        },
      ),
    );

    _instance = dio;
    return _instance!;
  }
}

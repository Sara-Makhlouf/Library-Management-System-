import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:library_mobile_app/core/network.dart';

class CustomerRepository {
  Future<Map<String, dynamic>> getProfile() async {
    final dio = await NetworkService.getInstance();
    try {
      final response = await dio.get('/customer');
      print('🟢 getProfile response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('🔴 getProfile DioException: ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? gender,
    String? dob,
    String? phone,
    String? lang,
    File? avatar,
  }) async {
    final dio = await NetworkService.getInstance();

    if (avatar != null) {
      print('📷 Avatar path: ${avatar.path}');
      print('📷 Avatar exists: ${await avatar.exists()}');
      print('📷 Avatar size: ${await avatar.length()} bytes');
    }

    final formMap = <String, dynamic>{
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
      if (dob != null) 'DOB': dob,
      if (phone != null) 'phone': phone,
      if (lang != null) 'lang': lang,
      if (avatar != null)
        'avatar': await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
          contentType: MediaType('image', _guessImageSubtype(avatar.path)),
        ),
    };

    try {
      final response = await dio.post(
        '/customer',
        data: FormData.fromMap(formMap),
        queryParameters: {'_method': 'PUT'},
      );
      print('🟢 updateProfile response status: ${response.statusCode}');
      print('🟢 updateProfile response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('🔴 updateProfile DioException: ${e.message}');
      print('🔴 Response data: ${e.response?.data}');
      rethrow;
    }
  }
}

String _guessImageSubtype(String path) {
  final ext = path.split('.').last.toLowerCase();
  switch (ext) {
    case 'png':
      return 'png';
    case 'webp':
      return 'webp';
    case 'heic':
      return 'heic';
    default:
      return 'jpeg';
  }
}

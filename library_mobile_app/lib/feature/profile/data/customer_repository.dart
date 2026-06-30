import 'dart:io';
import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';

/// يتعامل مع نقاط النهاية الخاصة ببيانات الزبون الحالي:
/// GET  /customer  → عرض البيانات
/// PUT  /customer   → تحديث البيانات (الاسم، الهاتف، الجنس، تاريخ الميلاد، اللغة، الصورة)
class CustomerRepository {
  /// جلب بيانات الملف الشخصي للزبون الحالي.
  Future<Map<String, dynamic>> getProfile() async {
    final dio = await NetworkService.getInstance();
    try {
      final response = await dio.get('/customer');
      return response.data;
    } on DioException catch (e) {
      print('🔴 getProfile DioException: ${e.message}');
      rethrow;
    }
  }

  /// تحديث البيانات الشخصية. كل الحقول اختيارية (sometimes) في الباك اند،
  /// لذلك يتم إرسال فقط الحقول التي تم تمريرها.
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? gender,
    String? dob,
    String? phone,
    String? lang,
    File? avatar,
  }) async {
    final dio = await NetworkService.getInstance();

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
        ),
    };

    try {
      // PUT مع ملف يتطلب multipart، ولأن Laravel لا يدعم PUT مع
      // multipart/form-data بشكل مباشر عبر بعض العملاء، نستخدم
      // POST مع override خاص بالـ method لضمان التوافق.
      final response = await dio.post(
        '/customer',
        data: FormData.fromMap(formMap),
        queryParameters: {'_method': 'PUT'},
      );
      print('🟢 updateProfile response status: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('🔴 updateProfile DioException: ${e.message}');
      print('🔴 Response data: ${e.response?.data}');
      rethrow;
    }
  }
}

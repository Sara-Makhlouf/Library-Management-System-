import 'dart:io';
import 'package:dio/dio.dart';

class AuthRepository {
  // إنشاء كائن Dio وإعداد الإعدادات الافتراضية إذا لزم الأمر
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    File? avatarFile,
  }) async {
    try {
      // تجهيز البيانات كـ FormData متوافقة مع توثيق البوستمان الناجح
      Map<String, dynamic> fields = {
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'gender': 'F', // القيم الافتراضية المأخوذة من البوستمان
        'DOB': '2005-06-13',
        'lang': 'ar',
      };

      // إضافة ملف الصورة في حال وجوده باستخدام MultipartFile الخاص بـ Dio
      if (avatarFile != null) {
        fields['avatar'] = await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(fields);

      // إرسال طلب الـ POST للباكيند
      final response = await _dio.post('/register', data: formData);

      // الـ Dio يقوم بعملية jsonDecode تلقائياً إذا كانت الاستجابة JSON
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'فشلت عملية إنشاء الحساب');
      }
    } on DioException catch (e) {
      // معالجة الأخطاء القادمة من السيرفر وإعادتها بشكل واضح للـ BLoC
      final errorMessage =
          e.response?.data?['message'] ?? 'حدث خطأ في الاتصال بالسيرفر';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }
}

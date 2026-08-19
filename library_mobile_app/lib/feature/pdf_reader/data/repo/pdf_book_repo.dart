import 'dart:io';

import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfBookRepository {
  PdfBookRepository({
    required Dio dio,
    Future<String?> Function()? tokenProvider,
  })  : _dio = dio,
        _tokenProvider = tokenProvider;

  final Dio _dio;
  final Future<String?> Function()? _tokenProvider;

  /// Downloads and saves a book PDF file in the temporary directory.
  /// Uses up to 3 attempts before final failure.
  Future<File> downloadAndGetBookPdf(int bookId) async {
    const maxAttempts = 3;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print(
          '📥 [PdfBookRepository] بدء تحميل الكتاب $bookId - محاولة $attempt/$maxAttempts',
        );

        final response = await _dio.get(
          '/books/$bookId/read',
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
            },
          ),
        );

        final data = response.data;
        final bytes = data is List<int>
            ? data
            : (data as List<dynamic>).cast<int>();

        if (bytes.isEmpty) {
          throw const PdfBookException('ملف الكتاب فارغ.');
        }

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/book_$bookId.pdf');
        await file.writeAsBytes(bytes, flush: true);

        print('✅ [PdfBookRepository] تم حفظ ملف PDF بنجاح: ${file.path}');
        return file;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;

        // Retry only on transient/network-like failures.
        final shouldRetry = attempt < maxAttempts &&
            (statusCode == null || statusCode >= 500 || statusCode == 408);

        if (shouldRetry) {
          print(
            '⚠️ [PdfBookRepository] فشل محاولة $attempt/$maxAttempts بسبب DioException، جاري إعادة المحاولة... (${e.message})',
          );
          continue;
        }

        if (statusCode == 403) {
          throw const PdfBookException('غير مسموح لك بالوصول إلى هذا الكتاب.');
        }

        if (statusCode == 404) {
          throw const PdfBookException('الكتاب غير موجود أو الرابط غير صحيح.');
        }

        if (statusCode == 401) {
          throw const PdfBookException('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.');
        }

        final message = e.response?.data is Map<String, dynamic>
            ? e.response?.data['message']?.toString() ??
                'فشل تحميل الكتاب، يرجى المحاولة لاحقاً.'
            : 'فشل تحميل الكتاب، يرجى المحاولة لاحقاً.';

        throw PdfBookException(message);
      } catch (e) {
        if (attempt < maxAttempts) {
          print('⚠️ [PdfBookRepository] فشل تحميل الكتاب في محاولة $attempt، جاري إعادة المحاولة... ($e)');
          continue;
        }

        print('❌ [PdfBookRepository] فشل تحميل PDF نهائياً: $e');
        throw PdfBookException('حدث خطأ أثناء تحميل الكتاب، يرجى المحاولة مرة أخرى.');
      }
    }

    throw const PdfBookException('حدث خطأ أثناء تحميل الكتاب، يرجى المحاولة مرة أخرى.');
  }
}

class PdfBookException implements Exception {
  const PdfBookException(this.message);

  final String message;

  @override
  String toString() => message;
}

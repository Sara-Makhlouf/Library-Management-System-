import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  // نبدأ بالوضع الفاتح كافتراضي
  ThemeCubit() : super(ThemeMode.light);

  // دالة بسيطة لتبديل الثيم بين الفاتح والداكن
  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

// library_mobile_app/core/app_bloc_observer.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    developer.log('الـ Bloc الحالي: ${bloc.runtimeType} -> الحالات: $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    developer.log('خطأ في الـ Bloc: ${bloc.runtimeType} -> الخطأ: $error');
    super.onError(bloc, error, stackTrace);
  }
}

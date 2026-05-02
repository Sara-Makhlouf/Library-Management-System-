part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final int tabIndex;
  final List<BookModel> popularBooks;
  final List<dynamic> offers; // ✅ أضفنا قائمة العروض (استبدلي dynamic بموديل العرض الخاص بك)
  final HomeStatus status;
  final HomeStatus offersStatus; // ✅ حالة منفصلة للعروض
  final String errorMessage;

  HomeState({
    this.tabIndex = 0,
    this.popularBooks = const [],
    this.offers = const [], // ✅ القيمة الافتراضية
    this.status = HomeStatus.initial,
    this.offersStatus = HomeStatus.initial, // ✅ القيمة الافتراضية
    this.errorMessage = '',
  });

  HomeState copyWith({
    int? tabIndex,
    List<BookModel>? popularBooks,
    List<dynamic>? offers, // ✅ إضافة هنا
    HomeStatus? status,
    HomeStatus? offersStatus, // ✅ إضافة هنا
    String? errorMessage,
  }) {
    return HomeState(
      tabIndex: tabIndex ?? this.tabIndex,
      popularBooks: popularBooks ?? this.popularBooks,
      offers: offers ?? this.offers, // ✅ تحديث هنا
      status: status ?? this.status,
      offersStatus: offersStatus ?? this.offersStatus, // ✅ تحديث هنا
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
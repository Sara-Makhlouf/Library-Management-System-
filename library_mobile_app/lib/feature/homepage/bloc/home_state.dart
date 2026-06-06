part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final int tabIndex;
  final List<BookModel> popularBooks;
  final List<dynamic> offers;
  final HomeStatus status;
  final HomeStatus offersStatus;
  final String errorMessage;

  HomeState({
    this.tabIndex = 0,
    this.popularBooks = const [],
    this.offers = const [],
    this.status = HomeStatus.initial,
    this.offersStatus = HomeStatus.initial,
    this.errorMessage = '',
  });

  HomeState copyWith({
    int? tabIndex,
    List<BookModel>? popularBooks,
    List<dynamic>? offers,
    HomeStatus? status,
    HomeStatus? offersStatus,
    String? errorMessage,
  }) {
    return HomeState(
      tabIndex: tabIndex ?? this.tabIndex,
      popularBooks: popularBooks ?? this.popularBooks,
      offers: offers ?? this.offers,
      status: status ?? this.status,
      offersStatus: offersStatus ?? this.offersStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

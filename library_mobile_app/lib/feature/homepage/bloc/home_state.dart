// library_mobile_app/feature/homepage/bloc/home_state.dart

part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final int tabIndex;
  final List<BookModel> popularBooks;
  final List<BookModel> searchBooks;
  final List<BookModel> categoryBooks;
  final List<CategoryModel> categories;
  final List<dynamic> offers;
  final HomeStatus status;
  final HomeStatus offersStatus;
  final HomeStatus searchStatus;
  final HomeStatus booksStatus;
  final HomeStatus categoriesStatus;
  final String searchQuery;
  final String errorMessage;

  HomeState({
    this.tabIndex = 0,
    this.popularBooks = const [],
    this.searchBooks = const [],
    this.categoryBooks = const [],
    this.categories = const [],
    this.offers = const [],
    this.status = HomeStatus.initial,
    this.offersStatus = HomeStatus.initial,
    this.searchStatus = HomeStatus.initial,
    this.booksStatus = HomeStatus.initial,
    this.categoriesStatus = HomeStatus.initial,
    this.searchQuery = '',
    this.errorMessage = '',
  });

  HomeState copyWith({
    int? tabIndex,
    List<BookModel>? popularBooks,
    List<BookModel>? searchBooks,
    List<BookModel>? categoryBooks,
    List<CategoryModel>? categories,
    List<dynamic>? offers,
    HomeStatus? status,
    HomeStatus? offersStatus,
    HomeStatus? searchStatus,
    HomeStatus? booksStatus,
    HomeStatus? categoriesStatus,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      tabIndex: tabIndex ?? this.tabIndex,
      popularBooks: popularBooks ?? this.popularBooks,
      searchBooks: searchBooks ?? this.searchBooks,
      categoryBooks: categoryBooks ?? this.categoryBooks,
      categories: categories ?? this.categories,
      offers: offers ?? this.offers,
      status: status ?? this.status,
      offersStatus: offersStatus ?? this.offersStatus,
      searchStatus: searchStatus ?? this.searchStatus,
      booksStatus: booksStatus ?? this.booksStatus,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

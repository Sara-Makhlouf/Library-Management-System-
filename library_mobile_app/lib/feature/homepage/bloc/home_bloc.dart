// library_mobile_app/feature/homepage/bloc/home_bloc.dart

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';
import 'package:library_mobile_app/feature/homepage/data/repository.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeState()) {
    on<ChangeTabEvent>((event, emit) {
      emit(state.copyWith(tabIndex: event.index));
    });
    on<GetPopularBooksEvent>((event, emit) async {
      developer.log(
        '⚡ تم استقبال حدث جلب الكتب الشعبية (GetPopularBooksEvent)',
      );
      emit(state.copyWith(status: HomeStatus.loading));
      try {
        final List<BookModel> popularResults = await repository.fetchBooks();
        developer.log(
          '🎉 تم جلب الكتب الشعبية بنجاح! العدد: ${popularResults.length}',
        );

        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            popularBooks: popularResults,
          ),
        );
      } catch (e) {
        developer.log('🚨 فشل جلب الكتب الشعبية داخل الـ Bloc بسبب: $e');
        emit(
          state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
        );
      }
    });
    on<FetchHomeBooksEvent>((event, emit) async {
      developer.log(
        '⚡ تم استقبال حدث FetchHomeBooksEvent، تحويل الطلب إلى GetPopularBooksEvent',
      );
      add(GetPopularBooksEvent());
    });
    on<SearchBooksEvent>((event, emit) async {
      developer.log(
        '⚡ تم استقبال حدث البحث (SearchBooksEvent) بنص: "${event.query}"',
      );
      emit(state.copyWith(searchQuery: event.query));

      if (event.query.trim().isEmpty) {
        developer.log(
          '🧹 نص البحث فارغ، تم تفريغ قائمة النتائج وإعادة الحالة لـ initial',
        );
        emit(
          state.copyWith(
            searchStatus: HomeStatus.initial,
            searchBooks: const [],
          ),
        );
        return;
      }

      emit(state.copyWith(searchStatus: HomeStatus.loading));
      try {
        final List<BookModel> results = await repository.searchBooks(
          event.query,
        );
        developer.log(
          '🎉 تم استلام نتائج البحث بنجاح! عدد الكتب: ${results.length}',
        );
        emit(
          state.copyWith(searchStatus: HomeStatus.loaded, searchBooks: results),
        );
      } catch (e) {
        developer.log('🚨 فشلت عملية البحث داخل الـ Bloc بسبب: $e');
        emit(
          state.copyWith(
            searchStatus: HomeStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<FetchBooksByCategoryEvent>((event, emit) async {
      developer.log(
        '⚡ استقبال حدث جلب كتب الفئة المعرفة بـ ID: ${event.categoryId}',
      );
      emit(state.copyWith(booksStatus: HomeStatus.loading));
      try {
        final List<BookModel> books = await repository.fetchBooks(
          categoryId: event.categoryId,
        );
        developer.log('✅ تم جلب كتب الفئة بنجاح. العدد: ${books.length}');
        emit(
          state.copyWith(booksStatus: HomeStatus.loaded, categoryBooks: books),
        );
      } catch (e) {
        developer.log('🚨 خطأ أثناء جلب كتب الفئة: $e');
        emit(
          state.copyWith(
            booksStatus: HomeStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
    on<FetchCategoriesEvent>((event, emit) async {
      developer.log('⚡ تم استقبال حدث جلب الفئات (FetchCategoriesEvent)');
      emit(state.copyWith(categoriesStatus: HomeStatus.loading));
      try {
        final List<CategoryModel> fetchedCategories = await repository
            .fetchCategories();
        developer.log(
          '✅ تم جلب الفئات بنجاح من السيرفر. العدد: ${fetchedCategories.length}',
        );
        emit(
          state.copyWith(
            categoriesStatus: HomeStatus.loaded,
            categories: fetchedCategories,
          ),
        );
      } catch (e) {
        developer.log('🚨 خطأ أثناء جلب الفئات داخل الـ Bloc: $e');
        emit(
          state.copyWith(
            categoriesStatus: HomeStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}

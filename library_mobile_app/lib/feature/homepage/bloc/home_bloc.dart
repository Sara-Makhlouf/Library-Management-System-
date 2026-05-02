import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    on<ChangeTabEvent>((event, emit) {
      emit(state.copyWith(tabIndex: event.index));
    });

    on<GetPopularBooksEvent>((event, emit) async {
      emit(state.copyWith(status: HomeStatus.loading));
      try {
        // final books = await repository.getBooks();
        emit(state.copyWith(status: HomeStatus.loaded, popularBooks: []));
      } catch (e) {
        emit(
          state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
        );
      }
    });

    // ✅ منطق جلب العروض الجديد
    on<GetOffersEvent>((event, emit) async {
      emit(state.copyWith(offersStatus: HomeStatus.loading));
      try {
        // محاكاة جلب البيانات
        await Future.delayed(const Duration(seconds: 1));
        // final fetchedOffers = await repository.getOffers();
        emit(
          state.copyWith(
            offersStatus: HomeStatus.loaded,
            offers: [], // ضعي البيانات القادمة من السيرفر هنا
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            offersStatus: HomeStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}

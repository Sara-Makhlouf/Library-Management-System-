import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favstate.dart';
import 'package:library_mobile_app/feature/favourite/data/repository.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repository;

  FavoriteBloc(this.repository) : super(FavoriteInitial()) {
    on<GetFavoritesEvent>(_onGetFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onGetFavorites(
    GetFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    try {
      final books = await repository.getFavorites();
      emit(FavoriteLoaded(books));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      // إرسال طلب التبديل للباك إند
      await repository.toggleFavorite(event.bookId);

      // إعادة جلب القائمة المحدثة مباشرة لتحديث الواجهة وحفظ الحالة
      final books = await repository.getFavorites();
      emit(FavoriteLoaded(books));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}

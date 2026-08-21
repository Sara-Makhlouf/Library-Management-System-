import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favstate.dart';
import 'package:library_mobile_app/feature/favourite/data/repository.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repository;

  FavoriteBloc(this.repository) : super(const FavoriteState()) {
    on<GetFavoritesEvent>(_onGetFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onGetFavorites(
    GetFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final books = await repository.getFavorites();
      emit(
        state.copyWith(
          isLoading: false,
          favoriteBooks: books,
          favoriteIds: books.map((b) => b.id).toSet(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    final wasFavorite = state.favoriteIds.contains(event.bookId);
    final optimisticIds = Set<int>.from(state.favoriteIds);
    wasFavorite
        ? optimisticIds.remove(event.bookId)
        : optimisticIds.add(event.bookId);

    emit(state.copyWith(favoriteIds: optimisticIds));

    try {
      await repository.toggleFavorite(event.bookId);

      final books = await repository.getFavorites();
      emit(
        state.copyWith(
          favoriteBooks: books,
          favoriteIds: books.map((b) => b.id).toSet(),
        ),
      );
    } catch (e) {
      final rollbackIds = Set<int>.from(state.favoriteIds);
      wasFavorite
          ? rollbackIds.add(event.bookId)
          : rollbackIds.remove(event.bookId);
      emit(
        state.copyWith(favoriteIds: rollbackIds, errorMessage: e.toString()),
      );
    }
  }
}

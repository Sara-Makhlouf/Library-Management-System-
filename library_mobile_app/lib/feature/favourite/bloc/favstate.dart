import 'package:library_mobile_app/feature/homepage/data/model.dart';

class FavoriteState {
  final List<BookModel> favoriteBooks;
  final Set<int> favoriteIds;
  final bool isLoading;
  final String? errorMessage;

  const FavoriteState({
    this.favoriteBooks = const [],
    this.favoriteIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  bool isFavorite(int bookId) => favoriteIds.contains(bookId);

  FavoriteState copyWith({
    List<BookModel>? favoriteBooks,
    Set<int>? favoriteIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoriteState(
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

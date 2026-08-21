abstract class FavoriteEvent {}

class GetFavoritesEvent extends FavoriteEvent {}

class ToggleFavoriteEvent extends FavoriteEvent {
  final int bookId;
  ToggleFavoriteEvent(this.bookId);
}

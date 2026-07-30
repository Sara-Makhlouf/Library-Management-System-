abstract class FavoriteEvent {}

// حدث لجلب قائمة المفضلة عند فتح الصفحة
class GetFavoritesEvent extends FavoriteEvent {}

// حدث لإضافة أو إزالة كتاب من المفضلة عند الضغط عزر القلب
class ToggleFavoriteEvent extends FavoriteEvent {
  final int bookId;
  ToggleFavoriteEvent(this.bookId);
}

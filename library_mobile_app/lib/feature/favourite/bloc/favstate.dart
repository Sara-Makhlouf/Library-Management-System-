import 'package:library_mobile_app/feature/homepage/data/model.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<BookModel> favoriteBooks;
  FavoriteLoaded(this.favoriteBooks);
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}

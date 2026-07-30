import 'package:library_mobile_app/feature/books/data/bookDetailsModel.dart';

abstract class BookDetailsState {}

class BookDetailsInitial extends BookDetailsState {}

class BookDetailsLoading extends BookDetailsState {}

class BookDetailsSuccess extends BookDetailsState {
  final BookDetailsModel book;
  BookDetailsSuccess({required this.book});
}

class BookDetailsError extends BookDetailsState {
  final String message;
  BookDetailsError({required this.message});
}

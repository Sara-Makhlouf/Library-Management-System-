import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/books/bloc/event.dart';
import 'package:library_mobile_app/feature/books/bloc/state.dart';
import 'package:library_mobile_app/feature/books/data/repository.dart';

class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final BookRepository repository;

  BookDetailsBloc({required this.repository}) : super(BookDetailsInitial()) {
    on<FetchBookDetailsEvent>((event, emit) async {
      emit(BookDetailsLoading());
      try {
        final book = await repository.getBookDetails(event.bookId);
        emit(BookDetailsSuccess(book: book));
      } catch (e) {
        emit(BookDetailsError(message: e.toString()));
      }
    });
  }
}

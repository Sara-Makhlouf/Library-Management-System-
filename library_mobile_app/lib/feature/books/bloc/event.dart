abstract class BookDetailsEvent {}

class FetchBookDetailsEvent extends BookDetailsEvent {
  final String bookId;
  FetchBookDetailsEvent({required this.bookId});
}

abstract class BookDetailsEvent {}

class FetchBookDetailsEvent extends BookDetailsEvent {
  final String bookId;

  FetchBookDetailsEvent({required this.bookId});
}

class ToggleWaitlistEvent extends BookDetailsEvent {
  final int bookId;
  ToggleWaitlistEvent(this.bookId);
}

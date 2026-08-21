abstract class BookRequestEvent {}

class FetchBookRequestsEvent extends BookRequestEvent {}

class SubmitBookRequestEvent extends BookRequestEvent {
  final String bookTitle;
  final String authorName;
  final String notes;

  SubmitBookRequestEvent({
    required this.bookTitle,
    required this.authorName,
    required this.notes,
  });
}

class ShowBookRequestDetailEvent extends BookRequestEvent {
  final int id;
  ShowBookRequestDetailEvent({required this.id});
}

class CancelBookRequestEvent extends BookRequestEvent {
  final int id;
  CancelBookRequestEvent({required this.id});
}

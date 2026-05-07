abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class IncreaseQuantityEvent extends CartEvent {
  final String bookId;
  IncreaseQuantityEvent(this.bookId);
}

class DecreaseQuantityEvent extends CartEvent {
  final String bookId;
  DecreaseQuantityEvent(this.bookId);
}

class RemoveBookEvent extends CartEvent {
  final String bookId;
  RemoveBookEvent(this.bookId);
}

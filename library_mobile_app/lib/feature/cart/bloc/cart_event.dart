abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class RemoveBookEvent extends CartEvent {
  final int itemId; // الـ id الخاص بعنصر السلة (Cart Item ID) وليس الـ bookId
  RemoveBookEvent(this.itemId);
}

class RemoveBookFromCartEvent extends CartEvent {
  final int cartItemId;
  RemoveBookFromCartEvent(this.cartItemId);
}

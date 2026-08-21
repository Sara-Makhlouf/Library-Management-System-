abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class RemoveBookEvent extends CartEvent {
  final int itemId;
  RemoveBookEvent(this.itemId);
}

class RemoveBookFromCartEvent extends CartEvent {
  final int cartItemId;
  RemoveBookFromCartEvent(this.cartItemId);
}

class UpdateQuantityEvent extends CartEvent {
  final int cartDetailId;
  final int quantity;

  UpdateQuantityEvent({required this.cartDetailId, required this.quantity});
}

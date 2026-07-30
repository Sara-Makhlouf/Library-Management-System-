import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartModel cart; // تحمل السلة كاملة بكل تفاصيلها
  CartLoaded(this.cart);
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

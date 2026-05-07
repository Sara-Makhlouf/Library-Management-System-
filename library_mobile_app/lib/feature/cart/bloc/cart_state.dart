import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';

abstract class CartState {}

class CartLoaded extends CartState {
  final List<CartBookModel> cartItems;
  final double totalAmount;
  CartLoaded(this.cartItems, this.totalAmount);
}

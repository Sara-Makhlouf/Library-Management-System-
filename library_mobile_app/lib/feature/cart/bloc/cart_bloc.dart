import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final List<CartBookModel> _cartItems = [
    CartBookModel(
      id: '1',
      title: 'كتاب تعلم فلتر',
      author: 'أحمد',
      price: 15000,
      imageUrl: 'lib/assets/images/photo_2026-05-04_21-45-57.jpg',
    ),
    CartBookModel(
      id: '2',
      title: 'أساسيات البرمجة',
      author: 'سارة',
      price: 12000,
      imageUrl: 'lib/assets/images/photo_2026-05-04_21-46-04.jpg',
    ),
  ];
  CartBloc() : super(CartLoaded([], 0.0)) {
    on<LoadCartEvent>((event, emit) {
      emit(CartLoaded(List.from(_cartItems), _calculateTotal()));
    });

    add(LoadCartEvent());
    on<IncreaseQuantityEvent>((event, emit) {
      final index = _cartItems.indexWhere((item) => item.id == event.bookId);
      if (index != -1) {
        _cartItems[index].quantity++;
        emit(CartLoaded(List.from(_cartItems), _calculateTotal()));
      }
    });

    on<DecreaseQuantityEvent>((event, emit) {
      final index = _cartItems.indexWhere((item) => item.id == event.bookId);
      if (index != -1 && _cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
        emit(CartLoaded(List.from(_cartItems), _calculateTotal()));
      }
    });

    on<RemoveBookEvent>((event, emit) {
      _cartItems.removeWhere((item) => item.id == event.bookId);
      emit(CartLoaded(List.from(_cartItems), _calculateTotal()));
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
}

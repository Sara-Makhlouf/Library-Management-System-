import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final List<CartBookModel> _cartItems = [
    // --- كتب الشراء ---
    CartBookModel(
      id: '1',
      title: 'كتاب تعلم فلتر وبناء التطبيقات',
      author: 'أحمد',
      price: 15000,
      imageUrl:
          'assets/images/photo_2026-05-04_21-46-04.jpg', // تعديل المسارات بناءً على الـ assets المتاحة لديكِ
      isBorrow: false,
    ),
    CartBookModel(
      id: '2',
      title: 'أساسيات البرمجة بلغة ++C',
      author: 'سارة',
      price: 12000,
      imageUrl: 'assets/images/photo_2026-05-04_21-46-04.jpg',
      isBorrow: false,
    ),

    // --- كتب الاستعارة ---
    CartBookModel(
      id: '3',
      title: 'هندسة البرمجيات المتقدمة',
      author: 'محمد',
      price: 30000, // رسم الاستعارة
      imageUrl: 'assets/images/photo_2026-05-04_21-46-04.jpg',
      isBorrow: true,
    ),
    CartBookModel(
      id: '4',
      title: 'مقدمة في الذكاء الاصطناعي',
      author: 'ولاء',
      price: 30000, // رسم الاستعارة
      imageUrl: 'assets/images/photo_2026-05-04_21-46-04.jpg',
      isBorrow: true,
    ),
  ];

  CartBloc() : super(CartLoaded([], 0.0)) {
    on<LoadCartEvent>((event, emit) {
      emit(CartLoaded(List.from(_cartItems), _calculateTotal()));
    });

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

    add(LoadCartEvent());
  }
  double _calculateTotal() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
}

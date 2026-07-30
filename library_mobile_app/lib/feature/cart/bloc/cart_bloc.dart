import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/data/repository.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  // استخدام كائن واحد ثابت للـ Repository لكل الـ Bloc
  final BookCartRepository cartRepository = BookCartRepository();

  CartBloc() : super(CartInitial()) {
    on<LoadCartEvent>((event, emit) async {
      emit(CartLoading());
      try {
        final cartModel = await cartRepository.getCart();
        emit(CartLoaded(cartModel));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    });

    on<RemoveBookFromCartEvent>((event, emit) async {
      print(
        '🔄 CartBloc: Received RemoveBookFromCartEvent for book ID: ${event.cartItemId}',
      );

      // حفظ الحالة السابقة احتياطياً
      final currentState = state;

      try {
        // 1. حذف العنصر من السيرفر باستخدام الـ book_id مباشرة
        await cartRepository.removeBookFromCart(event.cartItemId);

        // 2. جلب السلة المحدثة من السيرفر
        final updatedCart = await cartRepository.getCart();

        // 3. إصدار الحالة الجديدة
        emit(CartLoaded(updatedCart));
        print('✅ Book removed and cart reloaded successfully from server!');
      } catch (e) {
        print('❌ CartBloc Error while removing book: $e');
        emit(CartError(e.toString()));

        // في حال حدث خطأ، إعادة الحالة القديمة
        if (currentState is CartLoaded) {
          emit(currentState);
        }
      }
    });
  }
}

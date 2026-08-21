import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/data/repository.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
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
    on<UpdateQuantityEvent>((event, emit) async {
      final currentState = state;
      try {
        await cartRepository.updateQuantity(event.cartDetailId, event.quantity);

        final updatedCart = await cartRepository.getCart();

        emit(CartLoaded(updatedCart));
      } catch (e) {
        emit(CartError(e.toString()));

        if (currentState is CartLoaded) {
          emit(currentState);
        }
      }
    });
    on<RemoveBookFromCartEvent>((event, emit) async {
      print(
        '🔄 CartBloc: Received RemoveBookFromCartEvent for book ID: ${event.cartItemId}',
      );

      final currentState = state;

      try {
        await cartRepository.removeBookFromCart(event.cartItemId);

        final updatedCart = await cartRepository.getCart();

        emit(CartLoaded(updatedCart));
        print('✅ Book removed and cart reloaded successfully from server!');
      } catch (e) {
        print('❌ CartBloc Error while removing book: $e');
        emit(CartError(e.toString()));
        if (currentState is CartLoaded) {
          emit(currentState);
        }
      }
    });
  }
}

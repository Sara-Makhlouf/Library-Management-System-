import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';

class CartItemCard extends StatelessWidget {
  final CartBookModel item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFD8C8A8),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              item.imageUrl,
              width: 60,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${item.price} ل.س"),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Color.fromARGB(255, 96, 82, 50),
                  ),
                  onPressed: () {
                    context.read<CartBloc>().add(
                      DecreaseQuantityEvent(item.id),
                    );
                  },
                ),
                Text("${item.quantity}", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Color.fromARGB(255, 96, 82, 50),
                  ),
                  onPressed: () {
                    context.read<CartBloc>().add(
                      IncreaseQuantityEvent(item.id),
                    );
                  },
                ),
              ],
            ),

            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<CartBloc>().add(RemoveBookEvent(item.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

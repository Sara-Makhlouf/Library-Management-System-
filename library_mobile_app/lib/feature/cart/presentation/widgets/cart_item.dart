import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class CartItemCard extends StatelessWidget {
  final CartBookModel item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isBorrowItem = item.isBorrow ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2️⃣ استدعاء كلاس الترجمة
    final localizations = AppLocalizations.of(context)!;

    return Card(
      color: isDark ? AppColors.darkCard : const Color(0xFFD8C8A8),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: isDark ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imageUrl,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    // 3️⃣ استبدال النصوص الثابتة والمدمجة بمفاتيح مترجمة وتمرير السعر كمعامل
                    isBorrowItem
                        ? localizations.borrowPrice(item.price.toString())
                        : localizations.purchasePrice(item.price.toString()),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.primary
                          : (isBorrowItem
                                ? const Color.fromARGB(255, 96, 82, 50)
                                : Colors.black87),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (!isBorrowItem)
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: isDark
                          ? AppColors.primary
                          : const Color.fromARGB(255, 96, 82, 50),
                    ),
                    onPressed: () {
                      context.read<CartBloc>().add(
                        DecreaseQuantityEvent(item.id),
                      );
                    },
                  ),
                  Text(
                    "${item.quantity}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: isDark
                          ? AppColors.primary
                          : const Color.fromARGB(255, 96, 82, 50),
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
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 226, 105, 97),
              ),
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

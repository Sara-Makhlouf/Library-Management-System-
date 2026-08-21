import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final List<CartItemModel> allCartItems;

  const CartItemCard({
    super.key,
    required this.item,
    required this.allCartItems,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBorrowItem = item.type == 'borrow';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final accent = AppColors.primary;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    final bookTitle = item.book?.title ?? '';
    final bookCover = item.book?.cover ?? '';

    final int currentQuantity = allCartItems
        .where(
          (element) =>
              element.bookId == item.bookId && element.type == item.type,
        )
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bookCover.isNotEmpty
                ? Image.network(
                    bookCover,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _coverPlaceholder(accent),
                  )
                : _coverPlaceholder(accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isBorrowItem
                        ? localizations.borrowPrice(item.price.toString())
                        : localizations.purchasePrice(item.price.toString()),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isBorrowItem) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (currentQuantity > 1) {
                            context.read<CartBloc>().add(
                              UpdateQuantityEvent(
                                cartDetailId: item.id,
                                quantity: currentQuantity - 1,
                              ),
                            );
                          }
                        },
                        child: Icon(
                          Icons.remove_circle_outline,
                          size: 22,
                          color: currentQuantity > 1 ? accent : secondaryText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "$currentQuantity",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          context.read<CartBloc>().add(
                            UpdateQuantityEvent(
                              cartDetailId: item.id,
                              quantity: currentQuantity + 1,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 22,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              context.read<CartBloc>().add(RemoveBookFromCartEvent(item.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder(Color accent) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.book_outlined, color: accent, size: 26),
    );
  }
}

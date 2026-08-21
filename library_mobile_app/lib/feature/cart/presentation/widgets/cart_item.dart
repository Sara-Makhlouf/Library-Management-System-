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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    final accent = AppColors.primary;

    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    final isBorrowItem = item.type == 'borrow';

    final title = item.book?.title?.trim().isNotEmpty == true
        ? item.book!.title
        : 'Unknown book';

    final cover = item.book?.cover?.trim() ?? '';

    final quantity = allCartItems
        .where(
          (element) =>
              element.bookId == item.bookId && element.type == item.type,
        )
        .length;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =====================================================
            // BOOK COVER
            // =====================================================
            Hero(
              tag: 'cart-book-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: cover.isNotEmpty
                    ? Image.network(
                        cover,
                        width: 74,
                        height: 98,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return _coverPlaceholder(accent);
                        },
                        errorBuilder: (_, __, ___) {
                          return _coverPlaceholder(accent);
                        },
                      )
                    : _coverPlaceholder(accent),
              ),
            ),

            const SizedBox(width: 13),

            // =====================================================
            // BOOK INFORMATION
            // =====================================================
            Expanded(
              child: SizedBox(
                height: 98,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // TITLE + DELETE
                    // =================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 15,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        _deleteButton(context, accent),
                      ],
                    ),

                    // بدل Spacer حتى ما يصير overflow
                    const SizedBox(height: 5),

                    // =================================================
                    // TYPE
                    // =================================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isBorrowItem
                            ? Colors.blue.withOpacity(0.10)
                            : accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isBorrowItem
                                ? Icons.menu_book_outlined
                                : Icons.shopping_bag_outlined,
                            size: 12,
                            color: isBorrowItem ? Colors.blue : accent,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            isBorrowItem ? 'Borrow' : 'Purchase',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isBorrowItem ? Colors.blue : accent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // =================================================
                    // PRICE + QUANTITY
                    // =================================================
                    SizedBox(
                      height: 34,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              isBorrowItem
                                  ? localizations.borrowPrice(
                                      item.price.toString(),
                                    )
                                  : localizations.purchasePrice(
                                      item.price.toString(),
                                    ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          if (!isBorrowItem)
                            _quantitySelector(
                              context: context,
                              quantity: quantity,
                              accent: accent,
                              secondaryText: secondaryText,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // DELETE BUTTON
  // =============================================================

  Widget _deleteButton(BuildContext context, Color accent) {
    return Material(
      color: Colors.red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _showDeleteConfirmation(context);
        },
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            Icons.delete_outline_rounded,
            color: Colors.redAccent,
            size: 19,
          ),
        ),
      ),
    );
  }

  // =============================================================
  // QUANTITY SELECTOR
  // =============================================================

  Widget _quantitySelector({
    required BuildContext context,
    required int quantity,
    required Color accent,
    required Color secondaryText,
  }) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: accent.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quantityButton(
            icon: Icons.remove_rounded,
            enabled: quantity > 1,
            color: accent,
            onTap: quantity > 1
                ? () {
                    context.read<CartBloc>().add(
                      UpdateQuantityEvent(
                        cartDetailId: item.id,
                        quantity: quantity - 1,
                      ),
                    );
                  }
                : null,
          ),

          Container(
            constraints: const BoxConstraints(minWidth: 26),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          _quantityButton(
            icon: Icons.add_rounded,
            enabled: true,
            color: accent,
            onTap: () {
              context.read<CartBloc>().add(
                UpdateQuantityEvent(
                  cartDetailId: item.id,
                  quantity: quantity + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =============================================================
  // QUANTITY BUTTON
  // =============================================================

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        width: 30,
        height: 32,
        child: Icon(
          icon,
          size: 15,
          color: enabled ? color : color.withOpacity(0.25),
        ),
      ),
    );
  }

  // =============================================================
  // DELETE CONFIRMATION
  // =============================================================

  void _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Remove this book?',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'This book will be removed from your cart.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);

                          context.read<CartBloc>().add(
                            RemoveBookFromCartEvent(item.id),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Remove',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // COVER PLACEHOLDER
  // =============================================================

  Widget _coverPlaceholder(Color accent) {
    return Container(
      width: 74,
      height: 98,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.16), accent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        color: accent.withOpacity(0.7),
        size: 30,
      ),
    );
  }
}

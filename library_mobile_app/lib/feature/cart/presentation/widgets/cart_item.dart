import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isBorrowItem = item.type == 'borrow';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    final bookTitle = item.book?.title ?? '';
    final bookCover = item.book?.cover ?? '';

    return Card(
      color: isDark ? AppColors.darkCard : const Color(0xFFEFE3D3),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isDark ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // صورة الغلاف بنفس مقاسات شاشة المفضلة (عرض 60، ارتفاع 80)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: bookCover.isNotEmpty
                  ? Image.network(
                      bookCover,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.book, size: 50),
                    )
                  : const Icon(Icons.book, size: 50),
            ),
            const SizedBox(width: 15),

            // تفاصيل الكتاب
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الكتاب مع اختصار الزائد بـ ...
                  Text(
                    bookTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.textDark : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // السعر باللون الأخضر وتحت اسم الكتاب مباشرة
                  Text(
                    isBorrowItem
                        ? localizations.borrowPrice(item.price.toString())
                        : localizations.purchasePrice(item.price.toString()),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // أزرار زيادة ونقصان الكمية بجانب بعضها (تظهر في حالة الشراء فقط)
                  if (!isBorrowItem) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // إيفنت النقصان
                          },
                          child: Icon(
                            Icons.remove_circle_outline,
                            size: 20,
                            color: isDark
                                ? AppColors.primary
                                : const Color.fromARGB(255, 96, 82, 50),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "1",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // إيفنت الزيادة
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: isDark
                                ? AppColors.primary
                                : const Color.fromARGB(255, 96, 82, 50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // زر الحذف من السلة
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 226, 105, 97),
              ),
              onPressed: () {
                context.read<CartBloc>().add(
                  RemoveBookFromCartEvent(item.bookId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

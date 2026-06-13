// library_mobile_app/feature/homepage/presentation/widgets/book_search_card.dart

import 'package:flutter/material.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';

class BookSearchCard extends StatelessWidget {
  final BookModel book;
  final bool isDark;
  final VoidCallback onTapDetails;

  const BookSearchCard({
    super.key,
    required this.book,
    required this.isDark,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = (book.stock != null && book.stock! > 0);
    final String displayPrice = book.price != null
        ? '${book.price} ل.س'
        : 'مجاني';

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFD8C8A8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.cover != null
                    ? Image.network(
                        book.cover!,
                        width: 80,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholderImage(isDark),
                      )
                    : _buildPlaceholderImage(isDark),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authorName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          book.avgRating ?? '0.0',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            book.categoryName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.orange
                                  : const Color(0xFF685A39),
                            ),
                          ),
                        ),

                        Text(
                          displayPrice,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.withOpacity(0.12)
                                : Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: isAvailable ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAvailable ? 'متاح حالياً' : 'قيد الاستعارة',
                                style: TextStyle(
                                  color: isAvailable
                                      ? Colors.green[600]
                                      : Colors.red[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onTapDetails,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'التفاصيل',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.orange
                                      : const Color(0xFF685A39),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: isDark
                                    ? Colors.orange
                                    : const Color(0xFF685A39),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 80,
      height: 110,
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      child: const Icon(Icons.book, color: Colors.orange),
    );
  }
}

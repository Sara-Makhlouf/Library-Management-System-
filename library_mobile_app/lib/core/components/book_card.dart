import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/presentation/books/book_details_screen.dart';

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final bool isDark;

  const BookCard({required this.book, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookDetailsScreen(imagePath: book['image']),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cover image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                book['image'],
                height: book['height'],
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 300,
                errorBuilder: (_, __, ___) => Container(
                  height: book['height'],
                  color: isDark
                      ? AppColors.inputDark
                      : AppColors.accentLight.withOpacity(0.4),
                  child: Center(
                    child: Icon(
                      Icons.book_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            // info
            Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book['author'],
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark
                          ? AppColors.textDark.withOpacity(0.5)
                          : AppColors.textLight.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // price badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: book['price'] == 'Free'
                          ? Colors.green.withOpacity(0.12)
                          : AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      book['price'],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: book['price'] == 'Free'
                            ? Colors.green
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

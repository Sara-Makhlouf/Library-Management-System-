import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/presentation/books/book_details_screen.dart';

class Book extends StatefulWidget {
  final String categoryName;
  const Book({super.key, this.categoryName = 'History Books'});

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  String _sort = 'Default';

  final List<Map<String, dynamic>> _books = [
    {
      'image': 'assets/images/bookHis.png',
      'title': 'The Muqaddimah',
      'author': 'Ibn Khaldun',
      'price': '\$12',
      'height': 200.0,
    },
    {
      'image': 'assets/images/bookHis1.png',
      'title': 'Sapiens',
      'author': 'Yuval Harari',
      'price': 'Free',
      'height': 160.0,
    },
    {
      'image': 'assets/images/bookHis2.png',
      'title': 'The Silk Roads',
      'author': 'Peter Frankopan',
      'price': '\$9',
      'height': 185.0,
    },
    {
      'image': 'assets/images/bookHis3.png',
      'title': 'Guns & Steel',
      'author': 'Jared Diamond',
      'price': '\$14',
      'height': 175.0,
    },
    {
      'image': 'assets/images/bookHis4.jpg',
      'title': 'The Art of War',
      'author': 'Sun Tzu',
      'price': 'Free',
      'height': 195.0,
    },
    {
      'image': 'assets/images/bookHis1.png',
      'title': 'Civilization',
      'author': 'Niall Ferguson',
      'price': '\$11',
      'height': 165.0,
    },
    {
      'image': 'assets/images/bookHis2.png',
      'title': 'The Crusades',
      'author': 'Thomas Asbridge',
      'price': '\$8',
      'height': 180.0,
    },
    {
      'image': 'assets/images/bookHis3.png',
      'title': 'A Short History',
      'author': 'Bill Bryson',
      'price': '\$10',
      'height': 170.0,
    },
  ];

  List<Map<String, dynamic>> get _sorted {
    final list = List<Map<String, dynamic>>.from(_books);
    if (_sort == 'Price') {
      list.sort((a, b) {
        final aFree = a['price'] == 'Free';
        final bFree = b['price'] == 'Free';
        if (aFree && !bFree) return -1;
        if (!aFree && bFree) return 1;
        return a['price'].compareTo(b['price']);
      });
    } else if (_sort == 'Title') {
      list.sort((a, b) => a['title'].compareTo(b['title']));
    }
    return list;
  }

  void _showSortSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.accentDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 14),
            ...['Default', 'Title', 'Price'].map(
              (opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _sort == opt
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                  size: 20,
                ),
                title: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                onTap: () {
                  setState(() => _sort = opt);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final books = _sorted;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: 18,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            Text(
              '${books.length} books',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textDark.withOpacity(0.5)
                    : AppColors.textLight.withOpacity(0.5),
              ),
            ),
          ],
        ),
        actions: [
          // Sort button
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputDark : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.sort_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: MasonryGridView.builder(
          itemCount: books.length,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemBuilder: (context, index) {
            final book = books[index];
            return _BookCard(book: book, isDark: isDark)
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 60 * index),
                  duration: 300.ms,
                )
                .slideY(begin: 0.2, end: 0, duration: 300.ms);
          },
        ),
      ),
    );
  }
}

// ── Book card ─────────────────────────────────────────────────────────────
class _BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final bool isDark;

  const _BookCard({required this.book, required this.isDark});

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

// library_mobile_app/feature/presentation/books/book.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';
import 'package:library_mobile_app/feature/homepage/data/repository.dart';

class Book extends StatefulWidget {
  final CategoryModel category;

  const Book({super.key, required this.category});

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  String _sort = 'Default';
  List<BookModel> _getSortedBooks(List<BookModel> originalBooks) {
    final list = List<BookModel>.from(originalBooks);
    if (_sort == 'Price') {
      list.sort((a, b) {
        final aPrice = a.price ?? '';
        final bPrice = b.price ?? '';
        return aPrice.compareTo(bPrice);
      });
    } else if (_sort == 'Title') {
      list.sort((a, b) => a.title.compareTo(b.title));
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
    return BlocProvider(
      create: (context) =>
          HomeBloc(repository: HomeRepository())
            ..add(FetchBooksByCategoryEvent(categoryId: widget.category.id)),
      child: Scaffold(
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
          title: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final booksCount = state.categoryBooks.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  Text(
                    '$booksCount books',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textDark.withOpacity(0.5)
                          : AppColors.textLight.withOpacity(0.5),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            GestureDetector(
              onTap: _showSortSheet,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
                    Icon(
                      Icons.sort_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
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
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.booksStatus == HomeStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.booksStatus == HomeStatus.error) {
                return Center(
                  child: Text(
                    '🚨 خطأ أثناء تحميل الكتب: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state.categoryBooks.isEmpty) {
                return const Center(
                  child: Text('لا توجد كتب متوفرة في هذه الفئة حالياً.'),
                );
              }
              final sortedBooks = _getSortedBooks(state.categoryBooks);

              return MasonryGridView.builder(
                itemCount: sortedBooks.length,
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemBuilder: (context, index) {
                  final book = sortedBooks[index];

                  final double calculatedHeight = (index % 3 == 0)
                      ? 190.0
                      : (index % 3 == 1 ? 165.0 : 175.0);

                  return BookCard(
                        book: book,
                        isDark: isDark,
                        cardHeight: calculatedHeight,
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 60 * index),
                        duration: 300.ms,
                      )
                      .slideY(begin: 0.2, end: 0, duration: 300.ms);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Book card ─────────────────────────────────────────────────────────────
class BookCard extends StatelessWidget {
  final BookModel book;
  final bool isDark;
  final double cardHeight;

  const BookCard({
    super.key,
    required this.book,
    required this.isDark,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final String displayPrice =
        (book.price == null || book.price == '0' || book.price!.isEmpty)
        ? 'Free'
        : '${book.price} ل.س';

    final String baseUrl = "http://192.168.1.18:8000/storage/";

    String? fullCoverUrl;
    if (book.cover != null && book.cover!.isNotEmpty) {
      fullCoverUrl = book.cover!.startsWith('http')
          ? book.cover
          : '$baseUrl${book.cover}';
    }
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(Routes.bookDetails, arguments: fullCoverUrl),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: fullCoverUrl != null
                  ? Image.network(
                      fullCoverUrl,
                      height: cardHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        print(
                          "❌ لساته عم يفشل؟ اتأكدي إنو الملف موجود فعلياً بالمسار public/storage بالسيرفر",
                        );
                        return _buildPlaceholderIcon();
                      },
                    )
                  : _buildPlaceholderIcon(),
            ),
            Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
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
                    book.isbn != null
                        ? 'ISBN: ${book.isbn}'
                        : 'مكتبة دمشق ذكية',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: displayPrice == 'Free'
                          ? Colors.green.withOpacity(0.12)
                          : AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      displayPrice,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: displayPrice == 'Free'
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

  Widget _buildPlaceholderIcon() {
    return Container(
      height: cardHeight,
      color: isDark
          ? AppColors.inputDark
          : AppColors.accentLight.withOpacity(0.4),
      child: Center(
        child: Icon(Icons.book_outlined, color: AppColors.primary, size: 28),
      ),
    );
  }
}

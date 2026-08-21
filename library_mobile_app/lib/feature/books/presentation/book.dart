import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:library_mobile_app/core/constants.dart';
import 'package:library_mobile_app/core/theme.dart';

import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/data/repository.dart';
import 'package:library_mobile_app/feature/books/presentation/book_details_screen.dart';

import 'package:library_mobile_app/feature/favourite/bloc/favbloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favstate.dart';

import 'package:library_mobile_app/feature/pdf_reader/bloc/read_book_cubit.dart';
import 'package:library_mobile_app/feature/pdf_reader/data/repo/pdf_book_repo.dart';

import 'package:library_mobile_app/feature/books/waiting_list/Bloc/WaitingListBloc.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Repository/WaitingListRepository.dart';

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

  /// Converts price safely to a number.
  ///
  /// Handles:
  /// 100
  /// "100"
  /// "100.50"
  /// "100 ل.س"
  /// null
  double _parsePrice(dynamic value) {
    if (value == null) return 0;

    final cleaned = value
        .toString()
        .replaceAll(',', '')
        .replaceAll('ل.س', '')
        .replaceAll('SYP', '')
        .replaceAll('\$', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  List<BookModel> _getSortedBooks(List<BookModel> originalBooks) {
    final list = List<BookModel>.from(originalBooks);

    switch (_sort) {
      case 'Title A-Z':
        list.sort(
          (a, b) => a.title.trim().toLowerCase().compareTo(
            b.title.trim().toLowerCase(),
          ),
        );
        break;

      case 'Price Low-High':
        list.sort(
          (a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)),
        );
        break;

      case 'Price High-Low':
        list.sort(
          (a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)),
        );
        break;

      case 'Default':
      default:
        // Keep original API order.
        break;
    }

    return list;
  }

  void _showSortSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.darkCard
        : AppColors.backgroundLight;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    final options = [
      'Default',
      'Title A-Z',
      'Price Low-High',
      'Price High-Low',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: secondaryText.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.sort_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sort books',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose how you want to view the books',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                ...options.map((option) {
                  final selected = _sort == option;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          setState(() {
                            _sort = option;
                          });

                          Navigator.pop(sheetContext);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withOpacity(0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.35)
                                  : secondaryText.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary.withOpacity(0.12)
                                      : secondaryText.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _sortIcon(option),
                                  size: 19,
                                  color: selected
                                      ? AppColors.primary
                                      : secondaryText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: selected
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        key: const ValueKey('selected'),
                                        color: AppColors.primary,
                                        size: 22,
                                      )
                                    : Icon(
                                        Icons.circle_outlined,
                                        key: const ValueKey('unselected'),
                                        color: secondaryText.withOpacity(0.35),
                                        size: 22,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _sortIcon(String option) {
    switch (option) {
      case 'Title A-Z':
        return Icons.sort_by_alpha_rounded;

      case 'Price Low-High':
        return Icons.arrow_upward_rounded;

      case 'Price High-Low':
        return Icons.arrow_downward_rounded;

      case 'Default':
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    return BlocProvider(
      create: (context) =>
          HomeBloc(repository: HomeRepository())
            ..add(FetchBooksByCategoryEvent(categoryId: widget.category.id)),
      child: Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,

          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: primaryText,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),

          titleSpacing: 8,

          title: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final booksCount = state.categoryBooks.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$booksCount books',
                    style: TextStyle(fontSize: 11, color: secondaryText),
                  ),
                ],
              );
            },
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: _showSortSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.black.withOpacity(0.06),
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Sort',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        body: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.booksStatus == HomeStatus.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state.booksStatus == HomeStatus.error) {
                return _buildErrorState(context, state.errorMessage, isDark);
              }

              if (state.categoryBooks.isEmpty) {
                return _buildEmptyState(context, isDark);
              }

              final sortedBooks = _getSortedBooks(state.categoryBooks);

              return MasonryGridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 4, bottom: 24),
                itemCount: sortedBooks.length,

                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),

                mainAxisSpacing: 14,
                crossAxisSpacing: 14,

                itemBuilder: (context, index) {
                  final book = sortedBooks[index];

                  return BookCard(book: book, isDark: isDark)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 45 * index),
                        duration: 300.ms,
                      )
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                      );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 42,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No books available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'There are currently no books in this category.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String? errorMessage,
    bool isDark,
  ) {
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              errorMessage ?? 'Unable to load books.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOOK CARD
// ============================================================

class BookCard extends StatelessWidget {
  final BookModel book;
  final bool isDark;

  const BookCard({super.key, required this.book, required this.isDark});

  String _getDisplayPrice() {
    if (book.price == null || book.price!.trim().isEmpty || book.price == '0') {
      return 'Free';
    }

    return '${book.price} SYP';
  }

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    final price = _getDisplayPrice();
    final isFree = price == 'Free';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) =>
                        BookDetailsBloc(repository: BookRepository()),
                  ),

                  BlocProvider(
                    create: (context) => ReadBookCubit(
                      PdfBookRepository(
                        dio: Dio(
                          BaseOptions(
                            baseUrl: baseUrl,
                            connectTimeout: const Duration(seconds: 20),
                            receiveTimeout: const Duration(seconds: 20),
                            headers: {
                              'Accept': 'application/json',
                              'Content-Type': 'application/json',
                            },
                          ),
                        ),
                        tokenProvider: () async {
                          final prefs = await SharedPreferences.getInstance();

                          return prefs.getString(tokenKey);
                        },
                      ),
                    ),
                  ),

                  BlocProvider(
                    create: (context) =>
                        WaitingListBloc(WaitingListRepository()),
                  ),
                ],
                child: BookDetailsScreen(bookId: book.id.toString()),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.055),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================
              // COVER
              // ====================================================
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 0.72,
                    child: book.cover != null && book.cover!.isNotEmpty
                        ? Image.network(
                            book.cover!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) {
                              return _buildPlaceholder();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return Container(
                                color: isDark
                                    ? AppColors.inputDark
                                    : AppColors.accentLight.withOpacity(0.25),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholder(),
                  ),

                  // Favorite button
                  Positioned(
                    top: 9,
                    right: 9,
                    child: BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, favState) {
                        final isFav = favState.isFavorite(book.id);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              context.read<FavoriteBloc>().add(
                                ToggleFavoriteEvent(book.id),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withOpacity(0.45)
                                    : Colors.white.withOpacity(0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: isFav ? Colors.red : primaryText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Price badge
                  Positioned(
                    left: 9,
                    bottom: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isFree
                            ? Colors.green.withOpacity(0.92)
                            : AppColors.primary.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ====================================================
              // BOOK INFO
              // ====================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 11, 11, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                    ),

                    const SizedBox(height: 7),

                    if (book.isbn != null && book.isbn!.trim().isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 13,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              book.isbn!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 13,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Digital Library',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.inputDark, AppColors.darkCard]
              : [
                  AppColors.accentLight.withOpacity(0.55),
                  AppColors.backgroundLight,
                ],
        ),
      ),
      child: Center(
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

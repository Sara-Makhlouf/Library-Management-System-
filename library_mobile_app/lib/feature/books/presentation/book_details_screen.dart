import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/bloc/event.dart';
import 'package:library_mobile_app/feature/books/bloc/state.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Bloc/WaitingListBloc.dart';
import 'package:library_mobile_app/feature/books/waiting_list/event/WaitingListEvent.dart';
import 'package:library_mobile_app/feature/books/waiting_list/state/WaitingListState.dart';
import 'package:library_mobile_app/feature/cart/data/repository.dart';
import 'package:library_mobile_app/feature/pdf_reader/bloc/read_book_cubit.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  Color _bgColor = const Color(0xFF21180D);
  Color _textColor = Colors.white;

  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookDetailsBloc>().add(
        FetchBookDetailsEvent(bookId: widget.bookId),
      );
    });
  }

  // ============================================================
  // ADD BOOK TO CART
  // ============================================================

  Future<void> _addBook(String bookId, String type) async {
    try {
      final repository = BookCartRepository();

      await repository.addBookToCart(bookId, type);

      if (!mounted) return;

      _showSnackBar(
        type == 'buy'
            ? 'Book added to cart successfully'
            : 'Book added to borrowing list successfully',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ============================================================
  // EXTRACT COLORS
  // ============================================================

  Future<void> _extractColors(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      final ImageProvider imageProvider = imageUrl.startsWith('http')
          ? NetworkImage(imageUrl)
          : AssetImage(imageUrl);

      final generator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200),
        maximumColorCount: 5,
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      final color =
          generator.darkMutedColor?.color ??
          generator.darkVibrantColor?.color ??
          generator.dominantColor?.color ??
          const Color(0xFF21180D);

      setState(() {
        _bgColor = color;

        _textColor =
            ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87;
      });
    } catch (e) {
      debugPrint('Palette extraction failed: $e');
    }
  }

  // ============================================================
  // REVIEW SHEET
  // ============================================================

  void _showReviewSheet() {
    double selectedRating = 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark ? AppColors.darkCard : Colors.white;

    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              decoration: BoxDecoration(
                color: background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HANDLE
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.rate_review_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate this book',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Share your experience',
                            style: TextStyle(
                              color: textColor.withOpacity(.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final selected = index < selectedRating;

                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedScale(
                            scale: selected ? 1.15 : 1,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              selected
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 38,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    maxLines: 4,
                    cursorColor: AppColors.primary,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts about this book...',
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(.4),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(.05)
                          : Colors.black.withOpacity(.035),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: selectedRating == 0
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          .25,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Submit Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _bookImage(
    String imagePath, {
    double width = 145,
    double height = 205,
  }) {
    if (imagePath.isEmpty) {
      return _errorImage(width, height);
    }

    final image = imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errorImage(width, height),
          )
        : Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errorImage(width, height),
          );

    return ClipRRect(borderRadius: BorderRadius.circular(18), child: image);
  }

  Widget _errorImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 42),
    );
  }

  // ============================================================
  // RATING
  // ============================================================

  Widget _rating(dynamic rating, dynamic reviews, Color textColor) {
    final value = double.tryParse(rating?.toString() ?? '0') ?? 0;

    final filledStars = value.round().clamp(0, 5);

    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < filledStars
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: AppColors.primary,
            size: 17,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviews reviews)',
          style: TextStyle(color: textColor.withOpacity(.5), fontSize: 11),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color secondaryText,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 19),
            ),
            const SizedBox(height: 9),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: secondaryText, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color textColor,
    required Color secondaryText,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: secondaryText, fontSize: 10)),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION SHEET
  // ============================================================
void _showActionSheet({
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
    required String borrowText,
    required Color borrowColor,
    required IconData borrowIcon,
    required VoidCallback borrowAction,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final cardColor = isDark ? AppColors.darkCard : Colors.white;

        final bottomPadding = MediaQuery.of(sheetContext).padding.bottom;

        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'What would you like to do?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Choose an action for this book',
                style: TextStyle(color: secondaryText, fontSize: 12),
              ),

              const SizedBox(height: 22),

              // BORROW / WAITING
              _actionButton(
                icon: borrowIcon,
                title: borrowText,
                color: borrowColor,
                onTap: () {
                  Navigator.pop(sheetContext);
                  borrowAction();
                },
              ),

              const SizedBox(height: 12),

              // BUY
              _actionButton(
                icon: Icons.shopping_cart_outlined,
                title: 'Buy this book',
                color: AppColors.primary,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _addBook(widget.bookId, 'buy');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 21),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    final borderColor = isDark
        ? Colors.white.withOpacity(.06)
        : Colors.black.withOpacity(.055);

    final accent = AppColors.primary;

    return MultiBlocListener(
      listeners: [
        // ======================================================
        // WAITING LIST
        // ======================================================
        BlocListener<WaitingListBloc, WaitingListState>(
          listener: (context, state) {
            if (state is WaitingListActionSuccess) {
              _showSnackBar(state.message, isError: false);

              context.read<BookDetailsBloc>().add(
                FetchBookDetailsEvent(bookId: widget.bookId),
              );
            }

            if (state is WaitingListError) {
              _showSnackBar(state.message, isError: true);
            }
          },
        ),

        // ======================================================
        // READ BOOK
        // ======================================================
        BlocListener<ReadBookCubit, ReadBookState>(
          listener: (context, state) {
            if (state is ReadBookLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(color: accent),
                      ),
                    ),
                  );
                },
              );
            }

            if (state is ReadBookError) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              _showSnackBar(state.message, isError: true);
            }

            if (state is ReadBookSuccess) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Book Reader')),
                      body: SfPdfViewer.file(state.file),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],

      child: Scaffold(
        backgroundColor: scaffoldBg,

        // ======================================================
        // BODY
        // ======================================================
        body: BlocConsumer<BookDetailsBloc, BookDetailsState>(
          listener: (context, state) {
            if (state is BookDetailsSuccess) {
              _extractColors(state.book.cover ?? '');
            }
          },

          builder: (context, state) {
            // ====================================================
            // LOADING
            // ====================================================

            if (state is BookDetailsLoading) {
              return Center(child: CircularProgressIndicator(color: accent));
            }

            // ====================================================
            // ERROR
            // ====================================================

            if (state is BookDetailsError) {
              return _errorState(
                state.message,
                primaryText,
                secondaryText,
                accent,
              );
            }

            // ====================================================
            // SUCCESS
            // ====================================================

            if (state is BookDetailsSuccess) {
              final book = state.book;

              final imagePath = book.cover ?? '';

              final authors = book.authors
                  .map((author) => author['name']?.toString() ?? '')
                  .where((name) => name.isNotEmpty)
                  .join(', ');

              final authorsNames = authors.isEmpty ? 'Unknown Author' : authors;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),

                slivers: [
                  // =================================================
                  // HERO HEADER
                  // =================================================
                  SliverToBoxAdapter(
                    child: _buildHeroHeader(
                      context,
                      book,
                      imagePath,
                      authorsNames,
                      isDark,
                      accent,
                    ),
                  ),

                  // =================================================
                  // STATS
                  // =================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child:
                          Row(
                                children: [
                                  _statCard(
                                    value: '${book.totalPages ?? 0}',
                                    label: 'Pages',
                                    icon: Icons.menu_book_rounded,
                                    cardColor: cardColor,
                                    textColor: primaryText,
                                    secondaryText: secondaryText,
                                    borderColor: borderColor,
                                  ),
                                  const SizedBox(width: 10),
                                  _statCard(
                                    value: 'EN',
                                    label: 'Language',
                                    icon: Icons.language_rounded,
                                    cardColor: cardColor,
                                    textColor: primaryText,
                                    secondaryText: secondaryText,
                                    borderColor: borderColor,
                                  ),
                                  const SizedBox(width: 10),
                                  _statCard(
                                    value: '${book.stock ?? 0}',
                                    label: 'Copies',
                                    icon: Icons.inventory_2_outlined,
                                    cardColor: cardColor,
                                    textColor: primaryText,
                                    secondaryText: secondaryText,
                                    borderColor: borderColor,
                                  ),
                                ],
                              )
                              .animate(delay: 200.ms)
                              .fadeIn()
                              .slideY(begin: .1, end: 0),
                    ),
                  ),

                  // =================================================
                  // OVERVIEW
                  // =================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child:
                          Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: accent.withOpacity(.10),
                                            borderRadius: BorderRadius.circular(
                                              11,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.description_outlined,
                                            color: accent,
                                            size: 19,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Overview',
                                          style: TextStyle(
                                            color: primaryText,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      book.title ?? 'No overview available.',
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 13,
                                        height: 1.7,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate(delay: 270.ms)
                              .fadeIn()
                              .slideY(begin: .08, end: 0),
                    ),
                  ),

                  // =================================================
                  // BOOK INFORMATION
                  // =================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book Information',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 18),

                            _infoRow(
                              icon: Icons.person_outline_rounded,
                              title: 'Author',
                              value: authorsNames,
                              textColor: primaryText,
                              secondaryText: secondaryText,
                            ),

                            const SizedBox(height: 16),

                            _infoRow(
                              icon: Icons.inventory_2_outlined,
                              title: 'Availability',
                              value: book.isAvailable
                                  ? 'Available'
                                  : 'Currently unavailable',
                              textColor: primaryText,
                              secondaryText: secondaryText,
                            ),

                            const SizedBox(height: 16),

                            _infoRow(
                              icon: Icons.attach_money_rounded,
                              title: 'Price',
                              value: '\$${book.price ?? "0"}',
                              textColor: primaryText,
                              secondaryText: secondaryText,
                            ),
                          ],
                        ),
                      ).animate(delay: 320.ms).fadeIn(),
                    ),
                  ),

                  // =================================================
                  // REVIEWS
                  // =================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews',
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showReviewSheet,
                            icon: Icon(
                              Icons.edit_outlined,
                              color: accent,
                              size: 17,
                            ),
                            label: Text(
                              'Write review',
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // RATING CARD
                  // =================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(isDark ? .09 : .07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accent.withOpacity(.12)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${book.avgRating ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Readers rating',
                                    style: TextStyle(
                                      color: primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _rating(
                                    book.avgRating,
                                    book.totalReviews ?? 0,
                                    primaryText,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),

        // ========================================================
        // BOTTOM BAR
        // ========================================================
        bottomNavigationBar: BlocBuilder<BookDetailsBloc, BookDetailsState>(
          builder: (context, state) {
            final book = state is BookDetailsSuccess ? state.book : null;

            if (book == null) {
              return const SizedBox.shrink();
            }

            final isAvailable = book.isAvailable;

            final isWaiting = book.isWaitingLocally;

            String borrowText;
            Color borrowColor;
            IconData borrowIcon;
            VoidCallback borrowAction;

            if (isAvailable) {
              borrowText = 'Borrow';
              borrowColor = const Color(0xFFF59E0B);
              borrowIcon = Icons.menu_book_outlined;

              borrowAction = () async {
                await _addBook(widget.bookId, 'borrow');
              };
            } else if (!isWaiting) {
              borrowText = 'Join Waiting List';
              borrowColor = const Color(0xFFF59E0B);
              borrowIcon = Icons.hourglass_empty_rounded;

              borrowAction = () {
                context.read<WaitingListBloc>().add(
                  JoinWaitingListEvent(int.parse(widget.bookId)),
                );
              };
            } else {
              borrowText = 'Leave Waiting List';
              borrowColor = Colors.redAccent;
              borrowIcon = Icons.cancel_outlined;

              borrowAction = () {
                context.read<WaitingListBloc>().add(
                  LeaveWaitingListEvent(int.parse(widget.bookId)),
                );
              };
            }

            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? .25 : .08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // READ
                  Expanded(
                    child: _bottomButton(
                      icon: Icons.menu_book_rounded,
                      title: 'Read Book',
                      background: isDark
                          ? Colors.white.withOpacity(.08)
                          : Colors.black.withOpacity(.05),
                      foreground: isDark ? Colors.white : AppColors.primary,
                      onTap: () {
                        context.read<ReadBookCubit>().fetchAndOpenBook(
                          int.parse(widget.bookId),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ACTION
                  Expanded(
                    flex: 2,
                    child: _bottomButton(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Get Book',
                      background: accent,
                      foreground: Colors.white,
                      onTap: () {
                        _showActionSheet(
                          isDark: isDark,
                          textColor: primaryText,
                          secondaryText: secondaryText,
                          borrowText: borrowText,
                          borrowColor: borrowColor,
                          borrowIcon: borrowIcon,
                          borrowAction: borrowAction,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HERO HEADER
  // ============================================================

  Widget _buildHeroHeader(
    BuildContext context,
    dynamic book,
    String imagePath,
    String authorsNames,
    bool isDark,
    Color accent,
  ) {
    return Stack(
      children: [
        // BACKGROUND
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 12,
            16,
            28,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgColor, Color.lerp(_bgColor, Colors.black, .72)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _glassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    color: _textColor,
                    onTap: () => Navigator.pop(context),
                  ),
                  _glassButton(
                    icon: _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: _isBookmarked ? accent : _textColor,
                    onTap: () {
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // BOOK
              Hero(
                    tag: widget.bookId,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.45),
                            blurRadius: 35,
                            spreadRadius: 2,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: _bookImage(imagePath, width: 150, height: 215),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 450.ms)
                  .scale(begin: const Offset(.88, .88)),

              const SizedBox(height: 22),

              // TITLE
              Text(
                book.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // AUTHOR
              Text(
                authorsNames,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textColor.withOpacity(.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 14),

              // RATING
              _rating(book.avgRating, book.totalReviews ?? 0, _textColor),

              const SizedBox(height: 18),

              // PRICE + AVAILABILITY
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${book.price ?? "0"}',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: book.isAvailable
                          ? Colors.green.withOpacity(.16)
                          : Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: book.isAvailable
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          book.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // SUBTLE BLUR
        Positioned(
          right: -80,
          top: 100,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(.08),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GLASS BUTTON
  // ============================================================

  Widget _glassButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(.15)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTON
  // ============================================================

  Widget _bottomButton({
    required IconData icon,
    required String title,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: foreground, size: 20),
        label: Text(
          title,
          style: TextStyle(
            color: foreground,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
    String message,
    Color primaryText,
    Color secondaryText,
    Color accent,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryText, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BookDetailsBloc>().add(
                  FetchBookDetailsEvent(bookId: widget.bookId),
                );
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

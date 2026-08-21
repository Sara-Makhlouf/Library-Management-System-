import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/bloc/event.dart';
import 'package:library_mobile_app/feature/books/bloc/state.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Bloc/WaitingListBloc.dart';
import 'package:library_mobile_app/feature/books/waiting_list/event/WaitingListEvent.dart';
import 'package:library_mobile_app/feature/books/waiting_list/state/WaitingListState.dart';
import 'package:library_mobile_app/feature/cart/data/repository.dart';
import 'package:palette_generator/palette_generator.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;
  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  Color _bgColor = const Color(0xFF2a2010);
  Color _textColor = Colors.white;
  bool _isBookmarked = false;

  Future<void> _addBook(String bookId, String type) async {
    try {
      final repository = BookCartRepository();
      await repository.addBookToCart(bookId, type);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book added to cart successfully as $type'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookDetailsBloc>().add(
        FetchBookDetailsEvent(bookId: widget.bookId),
      );
    });
  }

  Future<void> _extractColors(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      final generator =
          await PaletteGenerator.fromImageProvider(
            imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : AssetImage(imageUrl) as ImageProvider,
            size: const Size(200, 200),
            maximumColorCount: 3,
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Palette generation timed out'),
          );
      if (!mounted) return;
      setState(() {
        _bgColor =
            generator.darkMutedColor?.color ??
            generator.dominantColor?.color ??
            const Color(0xFF2a2010);
        _textColor =
            ThemeData.estimateBrightnessForColor(_bgColor) == Brightness.dark
            ? Colors.white
            : Colors.black87;
      });
    } catch (e) {
      debugPrint('_extractColors failed or timed out: $e');
    }
  }

  void _showReviewSheet() {
    double selectedRating = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(_bgColor, Colors.black, 0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Rate this Book',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () => setSheet(() => selectedRating = i + 1.0),
                    icon: Icon(
                      i < selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                cursorColor: AppColors.primary,
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  hintStyle: TextStyle(color: _textColor.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;
    final accent = AppColors.primary;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    return BlocListener<WaitingListBloc, WaitingListState>(
      listener: (context, state) {
        if (state is WaitingListActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF22C55E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<BookDetailsBloc>().add(
            FetchBookDetailsEvent(bookId: widget.bookId),
          );
        } else if (state is WaitingListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: BlocConsumer<BookDetailsBloc, BookDetailsState>(
          listener: (context, state) {
            if (state is BookDetailsSuccess) {
              _extractColors(state.book.cover ?? '');
            }
          },
          builder: (context, state) {
            if (state is BookDetailsLoading) {
              return Center(child: CircularProgressIndicator(color: accent));
            } else if (state is BookDetailsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        state.message,
                        style: TextStyle(color: secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is BookDetailsSuccess) {
              final book = state.book;
              final imagePath = book.cover ?? '';
              final authorsNames = book.authors.isNotEmpty
                  ? book.authors
                        .map((author) => author['name'] ?? '')
                        .where((name) => name.isNotEmpty)
                        .join(', ')
                  : 'Unknown Author';

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _bgColor,
                            Color.lerp(_bgColor, Colors.black, 0.55)!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.of(context).padding.top + 8,
                        16,
                        20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _CircleBtn(
                                onTap: () => Navigator.of(context).pop(),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  size: 16,
                                  color: _textColor,
                                ),
                              ),
                              _CircleBtn(
                                onTap: () => setState(
                                  () => _isBookmarked = !_isBookmarked,
                                ),
                                child: Icon(
                                  _isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 18,
                                  color: accent,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 300.ms),

                          const SizedBox(height: 20),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                    tag: widget.bookId,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: imagePath.startsWith('http')
                                            ? Image.network(
                                                imagePath,
                                                width: 110,
                                                height: 155,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _errorImage(accent),
                                              )
                                            : Image.asset(
                                                imagePath,
                                                width: 110,
                                                height: 155,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _errorImage(accent),
                                              ),
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .scale(begin: const Offset(0.9, 0.9)),

                              const SizedBox(width: 16),

                              Expanded(
                                child:
                                    Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: _textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ...List.generate(5, (i) {
                                                  final int filledStars =
                                                      (double.tryParse(
                                                                (book.avgRating ??
                                                                        0)
                                                                    .toString(),
                                                              ) ??
                                                              0)
                                                          .floor();
                                                  return Icon(
                                                    i < filledStars
                                                        ? Icons.star_rounded
                                                        : Icons
                                                              .star_outline_rounded,
                                                    color: accent,
                                                    size: 14,
                                                  );
                                                }),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${book.avgRating ?? 0}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: _textColor,
                                                  ),
                                                ),
                                                Text(
                                                  ' (${book.totalReviews ?? 0})',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: _textColor
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: accent.withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                authorsNames,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: accent,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(
                                                  '\$${book.price ?? "0"}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: _textColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 40),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: book.isAvailable
                                                        ? Colors.green
                                                              .withOpacity(0.15)
                                                        : Colors.grey
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    book.isAvailable
                                                        ? 'Available'
                                                        : 'Unavailable',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: book.isAvailable
                                                          ? Colors.green
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                        .animate(delay: 150.ms)
                                        .fadeIn()
                                        .slideX(begin: 0.1, end: 0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child:
                          Row(
                                children: [
                                  _StatCard(
                                    value: '${book.totalPages ?? 0}',
                                    label: 'Pages',
                                    icon: Icons.menu_book_rounded,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    primaryText: primaryText,
                                    secondaryText: secondaryText,
                                    accent: accent,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    value: 'EN',
                                    label: 'Language',
                                    icon: Icons.language_rounded,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    primaryText: primaryText,
                                    secondaryText: secondaryText,
                                    accent: accent,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatCard(
                                    value: '${book.stock ?? 0}',
                                    label: 'Quantity',
                                    icon: Icons.calendar_today_rounded,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    primaryText: primaryText,
                                    secondaryText: secondaryText,
                                    accent: accent,
                                  ),
                                ],
                              )
                              .animate(delay: 200.ms)
                              .fadeIn()
                              .slideY(begin: 0.15, end: 0),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            book.title ?? 'No overview available.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.65,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ).animate(delay: 280.ms).fadeIn(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showReviewSheet,
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: accent,
                            ),
                            label: Text(
                              'Write a review',
                              style: TextStyle(color: accent, fontSize: 12),
                            ),
                          ),
                        ],
                      ).animate(delay: 340.ms).fadeIn(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        bottomNavigationBar: BlocBuilder<BookDetailsBloc, BookDetailsState>(
          builder: (context, state) {
            final book = state is BookDetailsSuccess ? state.book : null;
            final bool isAvailable = book?.isAvailable ?? true;
            final bool isWaiting = state is BookDetailsSuccess
                ? state.book.isWaitingLocally
                : false;

            String borrowText;
            Color borrowColor;
            IconData borrowIcon;
            VoidCallback borrowAction;

            if (isAvailable) {
              borrowText = 'Borrow';
              borrowColor = Colors.orange;
              borrowIcon = Icons.menu_book_outlined;
              borrowAction = () async {
                await _addBook(widget.bookId, 'borrow');
              };
            } else if (!isWaiting) {
              borrowText = 'Join Waiting List';
              borrowColor = Colors.orange;
              borrowIcon = Icons.hourglass_empty;
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
                color: isDark ? AppColors.darkCard : AppColors.backgroundLight,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.05),
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _addBook(widget.bookId, 'buy');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: borrowAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: borrowColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(borrowIcon, color: Colors.white, size: 20),
                        label: Text(
                          borrowText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _errorImage(Color accent) {
    return Container(
      width: 110,
      height: 155,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.book_outlined, color: accent, size: 36),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _CircleBtn({required this.onTap, required this.child});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color cardColor;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.cardColor,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: secondaryText)),
          ],
        ),
      ),
    );
  }
}

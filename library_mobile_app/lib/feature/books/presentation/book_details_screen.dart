import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/bloc/event.dart';
import 'package:library_mobile_app/feature/books/bloc/state.dart';
import 'package:library_mobile_app/feature/cart/data/repository.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:library_mobile_app/core/theme.dart';

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
          content: Text('Book added to cart successfully as $type 🛒'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
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
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        imageUrl.startsWith('http')
            ? NetworkImage(imageUrl)
            : AssetImage(imageUrl) as ImageProvider,
        size: const Size(200, 200),
        maximumColorCount: 3,
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
    } catch (_) {}
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

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: BlocConsumer<BookDetailsBloc, BookDetailsState>(
        listener: (context, state) {
          if (state is BookDetailsSuccess) {
            _extractColors(state.book.cover ?? '');
          }
        },
        builder: (context, state) {
          if (state is BookDetailsLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is BookDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
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
                : 'مؤلف مجهول';

            return CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────
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
                                color: AppColors.primary,
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
                                          color: Colors.black.withOpacity(0.4),
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
                                                  _errorImage(),
                                            )
                                          : Image.asset(
                                              imagePath,
                                              width: 110,
                                              height: 155,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _errorImage(),
                                            ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),

                            const SizedBox(width: 16),

                            // ── التفاصيل بجانب الغلاف (أسماء المؤلفين في صندوق رمادي فقط) ──
                            Expanded(
                              child:
                                  Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 1. اسم الكتاب
                                          Text(
                                            book.title ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // 2. النجوم وتقييم الكتاب
                                          Row(
                                            children: [
                                              ...List.generate(
                                                5,
                                                (i) => Icon(
                                                  i <
                                                          double.parse(
                                                            (book.avgRating ??
                                                                    0)
                                                                .toString(),
                                                          ).floor()
                                                      ? Icons.star_rounded
                                                      : Icons
                                                            .star_outline_rounded,
                                                  color: AppColors.primary,
                                                  size: 14,
                                                ),
                                              ),
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
                                                  color: _textColor.withOpacity(
                                                    0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          // 3. أسماء المؤلفين داخل صندوق رمادي متناسق
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.25,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              authorsNames,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          // 4. السعر
                                          Text(
                                            '\$${book.price ?? "0"}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: _textColor,
                                            ),
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

                // ── Stats cards ─────────────────────────────────────
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
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 10),
                                const _StatCard(
                                  value: 'EN',
                                  label: 'Language',
                                  icon: Icons.language_rounded,
                                  isDark: true,
                                ),
                                const SizedBox(width: 10),
                                _StatCard(
                                  value: '${book.stock ?? 0}',
                                  label: 'Quantity',
                                  icon: Icons.calendar_today_rounded,
                                  isDark: isDark,
                                ),
                              ],
                            )
                            .animate(delay: 200.ms)
                            .fadeIn()
                            .slideY(begin: 0.15, end: 0),
                  ),
                ),

                // ── Overview ────────────────────────────────────────
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
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          book.title ?? 'No overview available.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.65,
                            color: isDark
                                ? AppColors.textDark.withOpacity(0.7)
                                : AppColors.textLight.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ).animate(delay: 280.ms).fadeIn(),
                  ),
                ),

                // ── Reviews Section ─────────────────────────────────────
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
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showReviewSheet,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Write a review',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.accentDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Choose Action',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _addBook(widget.bookId, 'borrow');
                          },
                          child: const Text(
                            'Borrow Book (استعارة)',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _addBook(widget.bookId, 'buy');
                          },
                          child: const Text(
                            'Buy Book (شراء)',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
      ),
    );
  }

  Widget _errorImage() {
    return Container(
      width: 110,
      height: 155,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.book_outlined,
        color: AppColors.primary,
        size: 36,
      ),
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
  final bool isDark;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.accentDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textDark.withOpacity(0.5)
                    : AppColors.textLight.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/bloc/event.dart';
import 'package:library_mobile_app/feature/books/bloc/state.dart';
import 'package:library_mobile_app/feature/cart/data/repository.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:library_mobile_app/core/theme.dart';

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
          content: Text('Book added to cart successfully as $type 🛒'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
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
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        imageUrl.startsWith('http')
            ? NetworkImage(imageUrl)
            : AssetImage(imageUrl) as ImageProvider,
        size: const Size(200, 200),
        maximumColorCount: 3,
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
    } catch (_) {}
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

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: BlocConsumer<BookDetailsBloc, BookDetailsState>(
        listener: (context, state) {
          if (state is BookDetailsSuccess) {
            _extractColors(state.book.cover ?? '');
          }
        },
        builder: (context, state) {
          if (state is BookDetailsLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is BookDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
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
                : 'مؤلف مجهول';

            return CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────
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
                                color: AppColors.primary,
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
                                      color: Colors.black.withOpacity(0.4),
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
                                              _errorImage(),
                                        )
                                      : Image.asset(
                                          imagePath,
                                          width: 110,
                                          height: 155,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _errorImage(),
                                        ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(begin: const Offset(0.9, 0.9)),

                            const SizedBox(width: 16),

                            // ── صندوق رمادي يحتوي على: الاسم، النجوم، المؤلفين، والسعر ──
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25), // صندوق رمادي غامق وشفاف
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. اسم الكتاب
                                    Text(
                                      book.title ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // 2. النجوم وتقييم الكتاب
                                    Row(
                                      children: [
                                        ...List.generate(
                                          5,
                                          (i) => Icon(
                                            i <
                                                    double.parse(
                                                      (book.avgRating ?? 0)
                                                          .toString(),
                                                    ).floor()
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: AppColors.primary,
                                            size: 14,
                                          ),
                                        ),
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
                                            color: _textColor.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // 3. أسماء المؤلفين
                                    Text(
                                      authorsNames,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // 4. السعر
                                    Text(
                                      '\$${book.price ?? "0"}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.1, end: 0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Stats cards ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        _StatCard(
                          value: '${book.totalPages ?? 0}',
                          label: 'Pages',
                          icon: Icons.menu_book_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        const _StatCard(
                          value: 'EN',
                          label: 'Language',
                          icon: Icons.language_rounded,
                          isDark: true,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          value: '${book.id ?? 2024}',
                          label: 'Year',
                          icon: Icons.calendar_today_rounded,
                          isDark: isDark,
                        ),
                      ],
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15, end: 0),
                  ),
                ),

                // ── Overview ────────────────────────────────────────
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
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          book.title ?? 'No overview available.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.65,
                            color: isDark
                                ? AppColors.textDark.withOpacity(0.7)
                                : AppColors.textLight.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ).animate(delay: 280.ms).fadeIn(),
                  ),
                ),

                // ── Reviews Section ─────────────────────────────────────
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
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showReviewSheet,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Write a review',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.accentDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Choose Action',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _addBook(widget.bookId, 'borrow');
                          },
                          child: const Text(
                            'Borrow Book (استعارة)',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _addBook(widget.bookId, 'buy');
                          },
                          child: const Text(
                            'Buy Book (شراء)',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
      ),
    );
  }

  Widget _errorImage() {
    return Container(
      width: 110,
      height: 155,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.book_outlined,
        color: AppColors.primary,
        size: 36,
      ),
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
  final bool isDark;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.accentDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textDark.withOpacity(0.5)
                    : AppColors.textLight.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}  */
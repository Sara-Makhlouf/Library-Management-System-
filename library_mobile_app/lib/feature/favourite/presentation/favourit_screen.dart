import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favbloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favstate.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white60 : AppColors.textGrey;

    final accent = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        centerTitle: false,

        titleSpacing: 20,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Favourites',
              style: TextStyle(
                color: primaryText,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 3),

            BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                final count = state.favoriteBooks.length;

                return Text(
                  '$count ${count == 1 ? 'book' : 'books'} saved',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.favorite_rounded, color: accent, size: 21),
          ),
        ],
      ),

      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          // =========================================================
          // LOADING
          // =========================================================

          if (state.isLoading && state.favoriteBooks.isEmpty) {
            return _buildLoading(isDark: isDark, accent: accent);
          }

          // =========================================================
          // ERROR
          // =========================================================

          if (state.errorMessage != null && state.favoriteBooks.isEmpty) {
            return _buildError(
              context: context,
              message: state.errorMessage!,
              isDark: isDark,
              primaryText: primaryText,
              secondaryText: secondaryText,
              accent: accent,
            );
          }

          // =========================================================
          // EMPTY
          // =========================================================

          if (state.favoriteBooks.isEmpty) {
            return _buildEmpty(
              isDark: isDark,
              primaryText: primaryText,
              secondaryText: secondaryText,
              accent: accent,
            );
          }

          // =========================================================
          // LIST
          // =========================================================

          return RefreshIndicator(
            color: accent,
            backgroundColor: cardColor,

            onRefresh: () async {
              context.read<FavoriteBloc>().add(GetFavoritesEvent());

              await Future.delayed(const Duration(milliseconds: 500));
            },

            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),

              itemCount: state.favoriteBooks.length,

              itemBuilder: (context, index) {
                final book = state.favoriteBooks[index];

                return _FavoriteBookCard(
                  book: book,
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  accent: accent,
                  onRemove: () {
                    context.read<FavoriteBloc>().add(
                      ToggleFavoriteEvent(book.id),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ===============================================================
  // LOADING
  // ===============================================================

  Widget _buildLoading({required bool isDark, required Color accent}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 2.5, color: accent),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Loading favourites...',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ERROR
  // ===============================================================

  Widget _buildError({
    required BuildContext context,
    required String message,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required Color accent,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.red,
                size: 38,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondaryText, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<FavoriteBloc>().add(GetFavoritesEvent());
                },

                icon: const Icon(Icons.refresh_rounded, size: 19),

                label: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // EMPTY
  // ===============================================================

  Widget _buildEmpty({
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required Color accent,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 55,
                color: accent.withOpacity(0.65),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Your favourites are empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryText,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              'Save the books you love and\n'
              'find them here whenever you want.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryText,
                fontSize: 13.5,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_rounded, size: 17, color: accent),
                  const SizedBox(width: 7),
                  Text(
                    'Tap ♥ on a book to save it',
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

// ===================================================================
// FAVORITE BOOK CARD
// ===================================================================

class _FavoriteBookCard extends StatelessWidget {
  final dynamic book;
  final bool isDark;
  final Color cardColor;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;
  final VoidCallback onRemove;

  const _FavoriteBookCard({
    required this.book,
    required this.isDark,
    required this.cardColor,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.055)
        : Colors.black.withOpacity(0.045);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

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
                  offset: const Offset(0, 7),
                ),
              ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================================================
            // COVER
            // =======================================================
            _buildCover(),

            const SizedBox(width: 14),

            // =======================================================
            // BOOK INFORMATION
            // =======================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Category
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: secondaryText,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            book.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Price + Favorite
                    Row(
                      children: [
                        _buildPrice(),

                        const Spacer(),

                        _buildFavoriteButton(),
                      ],
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

  // ===============================================================
  // COVER
  // ===============================================================

  Widget _buildCover() {
    final cover = book.cover;

    return Container(
      width: 78,
      height: 108,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accent.withOpacity(0.08),
      ),

      clipBehavior: Clip.antiAlias,

      child: cover != null && cover.toString().isNotEmpty
          ? Image.network(
              cover.toString(),
              width: 78,
              height: 108,
              fit: BoxFit.cover,

              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  ),
                );
              },

              errorBuilder: (_, __, ___) {
                return _coverPlaceholder();
              },
            )
          : _coverPlaceholder(),
    );
  }

  // ===============================================================
  // COVER PLACEHOLDER
  // ===============================================================

  Widget _coverPlaceholder() {
    return Container(
      color: accent.withOpacity(0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: accent.withOpacity(0.65),
            size: 30,
          ),

          const SizedBox(height: 5),

          Text(
            'BOOK',
            style: TextStyle(
              color: accent.withOpacity(0.6),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PRICE
  // ===============================================================

  Widget _buildPrice() {
    final price = book.salePrice ?? book.price ?? '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell_outlined, size: 13, color: Colors.green),

          const SizedBox(width: 5),

          Text(
            '$price \$',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FAVORITE BUTTON
  // ===============================================================

  Widget _buildFavoriteButton() {
    return Material(
      color: Colors.red.withOpacity(0.09),
      borderRadius: BorderRadius.circular(11),

      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(11),

        child: const SizedBox(
          width: 38,
          height: 38,

          child: Icon(Icons.favorite_rounded, color: Colors.red, size: 20),
        ),
      ),
    );
  }
}

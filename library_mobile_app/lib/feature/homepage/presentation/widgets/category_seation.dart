import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/core/constantPage.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

IconData getCategoryIcon(String categoryName) {
  switch (categoryName.trim()) {
    case 'روايات':
      return Icons.menu_book_rounded;

    case 'تكنولوجيا':
      return Icons.computer_rounded;

    case 'تاريخ':
      return Icons.history_edu_rounded;

    case 'علوم':
      return Icons.science_rounded;

    case 'فن وأدب':
      return Icons.palette_rounded;

    case 'فلسفة':
      return Icons.psychology_rounded;

    case 'اقتصاد':
      return Icons.trending_up_rounded;

    default:
      return Icons.auto_stories_rounded;
  }
}

class BookCategoriesSection extends StatelessWidget {
  const BookCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final primaryText = isDark ? AppColors.textDark : const Color(0xFF2C2518);

    final secondaryText = isDark ? AppColors.textGrey : const Color(0xFF807765);

    final accentColor = isDark ? AppColors.primary : const Color(0xFF685A39);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================================================
            // HEADER
            // =============================================================
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.bookCategories,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Browse by category',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: accentColor,
                    size: 21,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =============================================================
            // CATEGORIES
            // =============================================================
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.categoriesStatus != current.categoriesStatus ||
                  previous.categories != current.categories ||
                  previous.errorMessage != current.errorMessage,
              builder: (context, state) {
                // ---------------------------------------------------------
                // LOADING
                // ---------------------------------------------------------

                if (state.categoriesStatus == HomeStatus.loading) {
                  return _LoadingGrid(isDark: isDark, accentColor: accentColor);
                }

                // ---------------------------------------------------------
                // ERROR
                // ---------------------------------------------------------

                if (state.categoriesStatus == HomeStatus.error) {
                  return _ErrorState(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    accentColor: accentColor,
                  );
                }

                // ---------------------------------------------------------
                // EMPTY
                // ---------------------------------------------------------

                if (state.categories.isEmpty) {
                  return _EmptyState(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    accentColor: accentColor,
                  );
                }

                // ---------------------------------------------------------
                // GRID
                // ---------------------------------------------------------

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                  ),
                  itemBuilder: (context, index) {
                    final CategoryModel category = state.categories[index];

                    return _CategoryCard(
                      category: category,
                      icon: getCategoryIcon(category.name),
                      isDark: isDark,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      accentColor: accentColor,
                      index: index,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY CARD
// =============================================================================

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final IconData icon;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color accentColor;
  final int index;

  const _CategoryCard({
    required this.category,
    required this.icon,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.accentColor,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: accentColor.withOpacity(0.08),
            highlightColor: accentColor.withOpacity(0.04),
            onTap: () {
              context.read<HomeBloc>().add(
                FetchBooksByCategoryEvent(categoryId: category.id),
              );

              Navigator.pushNamed(context, Routes.book, arguments: category);
            },
            child: Ink(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.045),
                  width: 1,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.045),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // ===========================================================
                  // DECORATIVE CIRCLE
                  // ===========================================================
                  Positioned(
                    right: -28,
                    top: -28,
                    child: Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.035),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    left: -35,
                    bottom: -40,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.02),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // ===========================================================
                  // CONTENT
                  // ===========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // ======================================================
                        // CATEGORY NAME — LEFT
                        // ======================================================
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: secondaryText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ======================================================
                        // CATEGORY ICON — RIGHT
                        // ======================================================
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(
                              isDark ? 0.13 : 0.09,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: accentColor, size: 25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 60 * index),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.06,
          end: 0,
          delay: Duration(milliseconds: 60 * index),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// =============================================================================
// LOADING GRID
// =============================================================================

class _LoadingGrid extends StatelessWidget {
  final bool isDark;
  final Color accentColor;

  const _LoadingGrid({required this.isDark, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, index) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.06)),
          ),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor.withOpacity(0.45),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// ERROR STATE
// =============================================================================

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color accentColor;

  const _ErrorState({
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: Colors.red.withOpacity(0.7),
              size: 27,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Unable to load categories',
            style: TextStyle(
              color: primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Please try again later',
            style: TextStyle(color: secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color accentColor;

  const _EmptyState({
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.07)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_outlined,
              color: accentColor.withOpacity(0.6),
              size: 27,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'No categories available',
            style: TextStyle(
              color: primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Categories will appear here',
            style: TextStyle(color: secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

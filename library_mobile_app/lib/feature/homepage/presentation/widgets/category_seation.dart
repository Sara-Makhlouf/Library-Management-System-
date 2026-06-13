import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
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
      return Icons.science_outlined;
    case 'فن وأدب':
      return Icons.palette_outlined;
    case 'فلسفة':
      return Icons.psychology_outlined;
    case 'اقتصاد':
      return Icons.trending_up_rounded;
    default:
      return Icons.bookmark_border_rounded;
  }
}

class BookCategoriesSection extends StatelessWidget {
  const BookCategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                localizations.bookCategories,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.primary : const Color(0xFF685A39),
                ),
              ),
            ),
            const SizedBox(height: 15),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.categoriesStatus != current.categoriesStatus ||
                  previous.categories != current.categories ||
                  previous.errorMessage != current.errorMessage,
              builder: (context, state) {
                if (state.categoriesStatus == HomeStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state.categoriesStatus == HomeStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'فشل تحميل الفئات: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (state.categories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('لا توجد فئات متاحة حالياً.'),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                  ),
                  itemBuilder: (context, index) {
                    final CategoryModel category = state.categories[index];

                    final IconData categoryIcon = getCategoryIcon(
                      category.name,
                    );

                    return GestureDetector(
                          onTap: () {
                            context.read<HomeBloc>().add(
                              FetchBooksByCategoryEvent(
                                categoryId: category.id,
                              ),
                            );

                            Navigator.pushNamed(
                              context,
                              Routes.book,
                              arguments: category,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : const Color(0xFFD8C8A8).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.primary.withOpacity(0.3)
                                    : const Color(0xFF685A39).withOpacity(0.3),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    category.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textDark
                                          : const Color(0xFF2C1E11),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),

                                Icon(
                                  categoryIcon,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.primary
                                      : const Color(0xFF685A39),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 50 * index),
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scaleXY(
                          begin: 0.95,
                          end: 1.0,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
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

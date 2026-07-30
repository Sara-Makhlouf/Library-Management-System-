import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/data/repository.dart';
import 'package:library_mobile_app/feature/books/presentation/book_details_screen.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

// استيراد ملفات المفضلة التي أنشأناها سابقاً
import 'package:library_mobile_app/feature/favourite/bloc/favbloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favstate.dart';
import 'package:library_mobile_app/feature/favourite/data/repository.dart';

class PopularBooksSlider extends StatefulWidget {
  const PopularBooksSlider({Key? key}) : super(key: key);

  @override
  State<PopularBooksSlider> createState() => _PopularBooksSliderState();
}

class _PopularBooksSliderState extends State<PopularBooksSlider> {
  late PageController _pageController;
  double _currentPage = 0.0;
  Timer? _autoScrollTimer;
  int _booksLength = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.55);
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentPage = _pageController.page ?? 0.0;
            });
          }
        });
      }
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _booksLength > 1) {
        int nextPage = _pageController.page!.round() + 1;

        if (nextPage >= _booksLength) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // تغليف السلايدر بـ BlocProvider خاص بالمفضلة لكي يعمل زر القلب بشكل صحيح
    return BlocProvider(
      create: (context) => FavoriteBloc(FavoriteRepository()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final books = state.popularBooks;
          _booksLength = books.length;

          if (state.status == HomeStatus.loading) {
            return const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (books.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification) {
                      _autoScrollTimer?.cancel();
                    } else if (notification is ScrollEndNotification) {
                      _autoScrollTimer?.cancel();
                      _startAutoScroll();
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: books.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final book = books[index];

                      double value = _currentPage - index;
                      Matrix4 matrix = Matrix4.identity();

                      if (value == 0) {
                        matrix = Matrix4.identity()..scale(1.0);
                      } else {
                        double scale = (1 - (value.abs() * 0.15)).clamp(
                          0.8,
                          1.0,
                        );
                        double translation = value * 25.0 * (isRtl ? -1 : 1);

                        matrix = Matrix4.identity()
                          ..scale(scale)
                          ..translate(-translation, value.abs() * 8);
                      }

                      return Transform(
                        transform: matrix,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => BookDetailsBloc(
                                      repository: BookRepository(),
                                    ),
                                    child: BookDetailsScreen(
                                      bookId: book.id.toString(),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      book.cover != null &&
                                              book.cover!.isNotEmpty
                                          ? book.cover!
                                          : "",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: isDark
                                                    ? AppColors.darkCard
                                                    : const Color(0xFFEFE3D3),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.book,
                                                    size: 50,
                                                    color: isDark
                                                        ? AppColors.textGrey
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // ======= تعديل زر الإعجاب هنا =======
                                              BlocConsumer<
                                                FavoriteBloc,
                                                FavoriteState
                                              >(
                                                listener: (context, state) {
                                                  // يمكن إضافة SnackBar هنا عند النجاح أو الخطأ إذا رغبت
                                                },
                                                builder: (context, favState) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      // إرسال حدث التبديل (إضافة/حذف) إلى الـ BLoC
                                                      context
                                                          .read<FavoriteBloc>()
                                                          .add(
                                                            ToggleFavoriteEvent(
                                                              book.id,
                                                            ),
                                                          );

                                                      // تغيير الحالة محلياً بشكل مؤقت لكي يتحدث الزر فوراً بالواجهة
                                                      setState(() {
                                                        book.isFavorite =
                                                            !book.isFavorite;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        book.isFavorite
                                                            ? Icons.favorite
                                                            : Icons
                                                                  .favorite_border,
                                                        color: book.isFavorite
                                                            ? Colors.red
                                                            : Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              // ====================================
                                            ],
                                          ),

                                          // صندوق رمادي شفاف يحيط بـ (اسم الكتاب، المؤلف، النجمات والـ rate)
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ), // صندوق رمادي شفاف
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  book.title ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  book.authorName ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    fontSize: 11,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      book.avgRating ?? '0.0',
                                                      style: const TextStyle(
                                                        color: Colors.amber,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

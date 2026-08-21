import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constants.dart';

import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/data/repository.dart';
import 'package:library_mobile_app/feature/books/presentation/book_details_screen.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Bloc/WaitingListBloc.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Repository/WaitingListRepository.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/pdf_reader/bloc/read_book_cubit.dart';
import 'package:library_mobile_app/feature/pdf_reader/data/repo/pdf_book_repo.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

import 'package:library_mobile_app/feature/favourite/bloc/favbloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favstate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // لا يوجد BlocProvider خاص بالمفضلة هون — نستخدم النسخة الوحيدة من الجذر
    return BlocBuilder<HomeBloc, HomeState>(
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

        final activeDot = _currentPage.round().clamp(0, books.length - 1);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
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
                    final proximity = (1 - value.abs()).clamp(0.0, 1.0);

                    if (value == 0) {
                      matrix = Matrix4.identity()..scale(1.0);
                    } else {
                      double scale = (1 - (value.abs() * 0.15)).clamp(0.8, 1.0);
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
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) => BookDetailsBloc(
                                        repository: BookRepository(),
                                      ),
                                    ),
                                    BlocProvider(
                                      create: (context) => WaitingListBloc(
                                        WaitingListRepository(),
                                      ),
                                    ),

                                    BlocProvider(
                                      create: (context) => ReadBookCubit(
                                        PdfBookRepository(
                                          dio: Dio(
                                            BaseOptions(
                                              baseUrl: baseUrl,
                                              connectTimeout: const Duration(
                                                seconds: 20,
                                              ),
                                              receiveTimeout: const Duration(
                                                seconds: 20,
                                              ),
                                              headers: {
                                                'Accept': 'application/json',
                                                'Content-Type':
                                                    'application/json',
                                              },
                                            ),
                                          ),
                                          tokenProvider: () async {
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            return prefs.getString(tokenKey);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                  child: BookDetailsScreen(
                                    bookId: book.id.toString(),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.18 + (proximity * 0.14),
                                  ),
                                  blurRadius: 16 + (proximity * 8),
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    book.cover != null && book.cover!.isNotEmpty
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
                                                  Icons.menu_book_rounded,
                                                  size: 46,
                                                  color: isDark
                                                      ? AppColors.textGrey
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                  ),

                                  // تدرّج ذكي: أعلى الكارد صافي عشان يبين الغلاف،
                                  // وتغميق تدريجي بس بالثلث السفلي لقراءة أوضح للنص.
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        stops: [0.0, 0.45, 1.0],
                                        colors: [
                                          Color(0xE6000000),
                                          Color(0x33000000),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ===== شارة التقييم: زجاجية بأعلى يمين الكارد =====
                                  Positioned(
                                    top: 10,
                                    right: isRtl ? null : 10,
                                    left: isRtl ? 10 : null,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 8,
                                          sigmaY: 8,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.32,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.18,
                                              ),
                                              width: 0.6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Colors.amber,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                book.avgRating ?? '0.0',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // ===== زر المفضلة: زجاجي بأعلى يسار الكارد =====
                                  Positioned(
                                    top: 10,
                                    left: isRtl ? null : 10,
                                    right: isRtl ? 10 : null,
                                    child:
                                        BlocBuilder<
                                          FavoriteBloc,
                                          FavoriteState
                                        >(
                                          builder: (context, favState) {
                                            final isFav = favState.isFavorite(
                                              book.id,
                                            );
                                            return GestureDetector(
                                              onTap: () {
                                                context
                                                    .read<FavoriteBloc>()
                                                    .add(
                                                      ToggleFavoriteEvent(
                                                        book.id,
                                                      ),
                                                    );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 8,
                                                    sigmaY: 8,
                                                  ),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: isFav
                                                          ? Colors.red
                                                                .withOpacity(
                                                                  0.28,
                                                                )
                                                          : Colors.black
                                                                .withOpacity(
                                                                  0.32,
                                                                ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.18),
                                                        width: 0.6,
                                                      ),
                                                    ),
                                                    child: AnimatedSwitcher(
                                                      duration: const Duration(
                                                        milliseconds: 200,
                                                      ),
                                                      transitionBuilder:
                                                          (child, anim) =>
                                                              ScaleTransition(
                                                                scale: anim,
                                                                child: child,
                                                              ),
                                                      child: Icon(
                                                        isFav
                                                            ? Icons.favorite
                                                            : Icons
                                                                  .favorite_border,
                                                        key: ValueKey(isFav),
                                                        color: isFav
                                                            ? Colors.redAccent
                                                            : Colors.white,
                                                        size: 17,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),

                                  // ===== عنوان الكتاب والمؤلف بأسفل الكارد =====
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          book.title ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Cairo',
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          book.authorName ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                            fontSize: 11.5,
                                            fontFamily: 'Cairo',
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

            const SizedBox(height: 12),

            // ===== مؤشر موقع السلايدر (dots) =====
            if (books.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(books.length, (index) {
                  final isActive = index == activeDot;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : (isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
          ],
        );
      },
    );
  }
}

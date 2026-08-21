import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/booksearchcard.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      context.read<HomeBloc>().add(SearchBooksEvent(''));
      setState(() {});
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<HomeBloc>().add(SearchBooksEvent(query));
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFD8C8A8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black38 : Colors.black12,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: localizations.searchYourBook,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? AppColors.primary
                          : const Color(0xFF685A39),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _debounce?.cancel();

                              context.read<HomeBloc>().add(
                                SearchBooksEvent(''),
                              );
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFD8C8A8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : Colors.black38,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  print('Sort pressed');
                },
                icon: Icon(
                  Icons.sort_by_alpha,
                  color: isDark ? AppColors.primary : const Color(0xFF685A39),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            print("حالة البحث الحالية في الواجهة هي: ${state.searchStatus}");
            if (state.searchQuery.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            if (state.searchStatus == HomeStatus.loading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.searchStatus == HomeStatus.loaded) {
              if (state.searchBooks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('عذراً، لم نجد أي كتاب يطابق بحثك!'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.searchBooks.length,
                itemBuilder: (context, index) {
                  final book = state.searchBooks[index];

                  return BookSearchCard(
                    book: book,
                    isDark: isDark,
                    onTapDetails: () {
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
                                create: (context) =>
                                    WaitingListBloc(WaitingListRepository()),
                              ),
                              // ✅ تمت الإضافة
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
                                          'Content-Type': 'application/json',
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
                  );
                },
              );
            }

            if (state.searchStatus == HomeStatus.error) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'حدث خطأ: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

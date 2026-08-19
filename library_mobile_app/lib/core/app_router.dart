// library_mobile_app/core/app_router.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/data/repository.dart';
import 'package:library_mobile_app/feature/books/presentation/book.dart';
import 'package:library_mobile_app/feature/books/presentation/book_details_screen.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favbloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/data/repository.dart';
import 'package:library_mobile_app/feature/favourite/presentation/favourit_screen.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';
import 'package:library_mobile_app/feature/homepage/data/repository.dart';
import 'package:library_mobile_app/feature/homepage/presentation/screens/home_page.dart';
import 'package:library_mobile_app/feature/notifications/notifications_screen.dart';
import 'package:library_mobile_app/feature/pdf_reader/bloc/read_book_cubit.dart';
import 'package:library_mobile_app/feature/pdf_reader/data/repo/pdf_book_repo.dart';
import 'package:library_mobile_app/feature/profile/presentation/profile.dart';
import 'package:library_mobile_app/feature/presentation/splash_screen.dart';
import 'package:library_mobile_app/feature/seeting_screen/presentation/seeting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature/payment_page/presentation/payment_screen.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(builder: (_) => const Splashscreen());

      case Routes.homePage:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => HomeBloc(repository: HomeRepository())
                  ..add(GetPopularBooksEvent())
                  ..add(FetchCategoriesEvent()),
              ),
              BlocProvider(create: (context) => CartBloc()),
            ],
            child: const HomeScreen(),
          ),
        );

      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const Profile());

      case Routes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case Routes.book:
        final category = settings.arguments as CategoryModel;

        return MaterialPageRoute(builder: (_) => Book(category: category));

      case Routes.bookDetails:
        final bookId = settings.arguments.toString();
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => BookDetailsBloc(repository: BookRepository()),
              ),
              BlocProvider(
                create: (_) => ReadBookCubit(
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
            ],
            child: BookDetailsScreen(bookId: bookId),
          ),
        );

      case Routes.payment:
        final existingCartBloc = settings.arguments as CartBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: existingCartBloc,
            child: const CheckoutScreen(),
          ),
        );
      case Routes.favorites:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => FavoriteBloc(FavoriteRepository())
              ..add(
                GetFavoritesEvent(),
              ), // استبدل الحدث بالاسم الصحيح لديك لجلب المفضلة إن وجد
            child: const FavoriteScreen(), // تأكد من اسم شاشة المفضلة لديك
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

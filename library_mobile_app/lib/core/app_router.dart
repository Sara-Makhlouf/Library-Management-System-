// library_mobile_app/core/app_router.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constantPage.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:library_mobile_app/feature/Bill/presentation/AllBillsScreen.dart';
import 'package:library_mobile_app/feature/Bill/presentation/BillDetailsScreen.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestBloc.dart';
import 'package:library_mobile_app/feature/BookRequest/data/BookRequestRepository.dart';
import 'package:library_mobile_app/feature/BookRequest/presentation/BookRequestsScreen.dart';
import 'package:library_mobile_app/feature/History/bloc/history_bloc.dart';
import 'package:library_mobile_app/feature/History/data/HistoryRepository.dart';
import 'package:library_mobile_app/feature/History/presentation/OrderHistoryScreen.dart';
import 'package:library_mobile_app/feature/books/bloc/bloc.dart';
import 'package:library_mobile_app/feature/books/data/repository.dart';
import 'package:library_mobile_app/feature/books/presentation/book.dart';
import 'package:library_mobile_app/feature/books/presentation/book_details_screen.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Bloc/WaitingListBloc.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Repository/WaitingListRepository.dart';
import 'package:library_mobile_app/feature/books/waiting_list/presentation/MyWaitingListScreen.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favbloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/presentation/favourit_screen.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/data/model.dart';
import 'package:library_mobile_app/feature/homepage/data/repository.dart';
import 'package:library_mobile_app/feature/homepage/presentation/screens/home_page.dart';
import 'package:library_mobile_app/feature/notifications/presentation/notifications_screen.dart';
import 'package:library_mobile_app/feature/pdf_reader/bloc/read_book_cubit.dart';
import 'package:library_mobile_app/feature/pdf_reader/data/repo/pdf_book_repo.dart';
import 'package:library_mobile_app/feature/profile/presentation/profile.dart';
import 'package:library_mobile_app/feature/presentation/splash_screen.dart';
import 'package:library_mobile_app/feature/seeting_screen/presentation/seeting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(builder: (_) => const Splashscreen());

      case Routes.homePage:
        return MaterialPageRoute(
          builder: (context) {
            context.read<FavoriteBloc>().add(GetFavoritesEvent());

            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => HomeBloc(repository: HomeRepository())
                    ..add(GetPopularBooksEvent())
                    ..add(FetchCategoriesEvent()),
                ),
                BlocProvider(create: (context) => CartBloc()),
              ],
              child: const HomeScreen(),
            );
          },
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
      case Routes.myWaitingList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => WaitingListBloc(WaitingListRepository()),

            child: const MyWaitingListScreen(),
          ),
        );
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
              BlocProvider(
                create: (_) => WaitingListBloc(WaitingListRepository()),
              ),
            ],
            child: BookDetailsScreen(bookId: bookId),
          ),
        );

      case Routes.bookRequests:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                BookRequestBloc(repository: BookRequestRepository()),
            child: const BookRequestsScreen(),
          ),
        );
      case Routes.favorites:
        return MaterialPageRoute(builder: (_) => const FavoriteScreen());

      case Routes.billDetails:
        final billId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BillDetailsScreen(billId: billId),
        );
      case Routes.orderHistory:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => HistoryBloc(HistoryRepository()),
            child: const OrderHistoryScreen(),
          ),
        );

      case Routes.allBills:
        return MaterialPageRoute(builder: (_) => const AllBillsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

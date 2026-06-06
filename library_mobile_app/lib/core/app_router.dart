import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/presentation/screens/home_page.dart';
import 'package:library_mobile_app/feature/notifications/notifications_screen.dart';
import 'package:library_mobile_app/feature/presentation/books/book.dart';
import 'package:library_mobile_app/feature/presentation/books/book_details_screen.dart';
import 'package:library_mobile_app/feature/presentation/profile.dart';
import 'package:library_mobile_app/feature/presentation/splash_screen.dart';
import 'package:library_mobile_app/feature/seeting_screen/presentation/seeting_screen.dart';
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
                create: (context) => HomeBloc()..add(GetPopularBooksEvent()),
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
        // استقبال اسم الفئة الممررة من صفحة الفئات
        final categoryTitle = settings.arguments as String? ?? 'الكل';

        return MaterialPageRoute(
          builder: (_) =>
              Book(categoryName: categoryTitle), // نقوم بتمرير الاسم هنا للشاشة
        );

      case Routes.bookDetails:
        final imagePath = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BookDetailsScreen(imagePath: imagePath),
        );

      case Routes.payment:
        final existingCartBloc = settings.arguments as CartBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: existingCartBloc,
            child: const CheckoutScreen(),
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

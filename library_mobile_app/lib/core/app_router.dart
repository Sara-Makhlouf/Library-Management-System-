import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/presentation/screens/home_page.dart';
import 'package:library_mobile_app/feature/presentation/splash_screen.dart';

import '../feature/payment_page/data/payment_mode.dart';
import '../feature/payment_page/presentation/payment_screen.dart'; // تأكد من الاستيراد الصحيح

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute: // التطبيق يبدأ من هنا
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
      case Routes.payment:
        // نتحقق من البيانات المرسلة (الـ mode)
        final mode = settings.arguments as PaymentMode;

        return MaterialPageRoute(builder: (_) => CheckoutScreen(mode: mode));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

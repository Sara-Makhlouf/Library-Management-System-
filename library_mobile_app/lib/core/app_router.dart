import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/presentation/screens/home_page.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => HomeBloc()..add(GetPopularBooksEvent()),
            child: const HomeScreen(),
          ),
        );
      case Routes.homePage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => HomeBloc()..add(GetPopularBooksEvent()),
            child: const HomeScreen(),
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

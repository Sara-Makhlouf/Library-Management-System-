import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/app_router.dart';
import 'package:library_mobile_app/core/constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.initialRoute, // سيبدأ من '/' الذي هو SplashScreen
      onGenerateRoute: AppRouter.generateRoute,
      title: 'Library App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

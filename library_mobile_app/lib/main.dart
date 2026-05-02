import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'core/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

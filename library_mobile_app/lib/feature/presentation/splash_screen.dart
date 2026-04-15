import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/feature/presentation/tabs_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Image.asset("assets/logo.png", width: size.width * 0.7)
            .animate(
              onComplete: (v) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => TabsScreen()),
                );
              },
            )
            .fadeIn(duration: Duration(milliseconds: 500))
            .fadeOut(
              delay: Duration(seconds: 2),
              duration: Duration(milliseconds: 500),
            ),
      ),
    );
  }
}

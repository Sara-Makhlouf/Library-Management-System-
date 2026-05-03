import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/feature/presentation/signin_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    // الانتظار لمدة 3 ثواني ثم الانتقال
    Future.delayed(const Duration(seconds: 3), () {
      // pushReplacementNamed تضمن عدم عودة المستخدم للسبلاش عند الضغط على زر الرجوع
      Navigator.pushReplacementNamed(context, Routes.homePage);
    });
  }

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
                  CupertinoPageRoute(builder: (context) => SigninScreen()),
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

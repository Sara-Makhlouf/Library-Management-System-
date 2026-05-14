import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/presentation/signin_screen.dart';

class OnboardingThree extends StatelessWidget {
  const OnboardingThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          Image.asset('assets/images/book3.jpg', fit: BoxFit.cover),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.96),
                ],
                stops: const [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),

          // bottom content
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 28, 24, MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text('HIBR & WARAQ',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: Colors.white70, letterSpacing: 1.5)),

                  const SizedBox(height: 12),

                  const Text('Build Your\nCollection.',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                      color: Colors.white, height: 1.25))
                      .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 8),

                  Text('Save your favorites, track what you\'ve read, and grow your personal library.',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65), height: 1.6))
                      .animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Row(children: [
                        _Dot(active: false),
                        _Dot(active: false),
                        _Dot(active: true),
                      ]),

                      Row(children: [

                        // back
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // get started
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 600),
                              pageBuilder: (_, __, ___) => const SigninScreen(),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(opacity: animation, child: child),
                            ),
                          ),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text('Get Started',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ).animate(delay: 200.ms).fadeIn(),

                      ]),

                    ],
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 20 : 6,
      height: 4,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

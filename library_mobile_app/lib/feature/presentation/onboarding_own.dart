import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/presentation/Onboarding_tow.dart';
import 'package:library_mobile_app/feature/presentation/signin_screen.dart';
class OnboardingOne extends StatelessWidget {
  const OnboardingOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // صورة الخلفية
          Image.asset('assets/images/book1.jpg', fit: BoxFit.cover),

          // overlay
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

          // skip
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SigninScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                ),
                child: const Text('Skip',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ).animate().fadeIn(duration: 400.ms),
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

                  const Text('Your Library,\nAnywhere.',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                      color: Colors.white, height: 1.25))
                      .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 8),

                  Text('Borrow, buy, or read digitally — thousands of books at your fingertips.',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65), height: 1.6))
                      .animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // dots
                      Row(children: [
                        _Dot(active: true),
                        _Dot(active: false),
                        _Dot(active: false),
                      ]),

                      // next
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OnboardingTwo()),
                        ),
                        child: Container(
                          width: 56, height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                        ),
                      ).animate(delay: 200.ms).fadeIn(),

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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

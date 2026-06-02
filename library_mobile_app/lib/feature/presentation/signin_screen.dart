import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:library_mobile_app/core/constant.dart';
=======
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:library_mobile_app/core/components/custom_button.dart';
import 'package:library_mobile_app/core/components/decorCircle.dart';
import 'package:library_mobile_app/core/components/shake_widget.dart';
import 'package:library_mobile_app/core/components/social_button.dart';
import 'package:library_mobile_app/core/components/theme_toggle.dart';
>>>>>>> origin/mohammed-frontend
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/core/theme_cubit.dart';
import 'package:library_mobile_app/feature/notifications/notifications_screen.dart';
import 'package:library_mobile_app/feature/presentation/register.dart';
import 'package:library_mobile_app/core/components/custom_input_field.dart';
import 'package:library_mobile_app/core/components/custom_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),

                    Image.asset("lib/assets/images/logo.png.png", height: 200),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone_android_rounded),
                        prefixIconColor: AppColors.iconscol,
                        hintText: "Enter Phone Number",
                        hintStyle: TextStyle(color: AppColors.textGrey),
                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    TextField(
                      cursorColor: Colors.black,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_open),
                        prefixIconColor: AppColors.iconscol,
                        hintStyle: TextStyle(color: AppColors.textGrey),
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(Routes.homePage);
                        },
                        child: Text(
                          "login",
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "I foregot password",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 199, 16, 16),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => Register(),
                              ),
                            );
                          },
                          child: Text(
                            "I dont have accont",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 5, 110, 197),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    socialButton(
                      text: "Google",
                      asset: "assets/google.png",
                      bgColor: Colors.white,
                      textColor: Colors.black,
                      border: true,
                    ),

                    SizedBox(height: 12),

                    socialButton(
                      text: "Facebook",
                      asset: "assets/facebook.png",
                      bgColor: Color.fromARGB(255, 24, 79, 152),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 12),

                socialButton(
                  text: "Apple",
                  asset: "assets/apple.png",
                  bgColor: const Color.fromARGB(255, 255, 255, 255),
                  textColor: const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
=======
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
>>>>>>> origin/mohammed-frontend
  }

  void _onLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _shakeKey.currentState?.shake();
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.accentLight,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: DecorCircle(
              size: 220,
              color: AppColors.primary,
              opacity: isDark ? 0.08 : 0.13,
            ),
          ),
          Positioned(
            top: size.height * 0.15,
            right: -80,
            child: DecorCircle(
              size: 180,
              color: AppColors.primary,
              opacity: isDark ? 0.05 : 0.09,
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            left: size.width * 0.2,
            child: DecorCircle(
              size: 120,
              color: AppColors.primary,
              opacity: isDark ? 0.04 : 0.07,
            ),
          ),

          Positioned(
            top: size.height * 0.09,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: size.width * 0.40)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 10),
                Text(
                  'Hibr & Waraq',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 4),
                Text(
                  'Your digital library',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: isDark
                        ? AppColors.textDark.withOpacity(0.5)
                        : AppColors.textLight.withOpacity(0.55),
                  ),
                ).animate(delay: 350.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: ThemeToggle(isDark: isDark)
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.3, end: 0),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child:
                ShakeWidget(
                      key: _shakeKey,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 100),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.accentDark : Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.08,
                              ),
                              blurRadius: 30,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            28,
                            32,
                            28,
                            MediaQuery.of(context).viewInsets.bottom + 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                    'Welcome back',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textDark
                                          : AppColors.textLight,
                                    ),
                                  )
                                  .animate(delay: 100.ms)
                                  .fadeIn()
                                  .slideY(begin: 0.2, end: 0),

                              const SizedBox(height: 4),

                              Text(
                                'Sign in to continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.textDark.withOpacity(0.55)
                                      : AppColors.textLight.withOpacity(0.55),
                                ),
                              ).animate(delay: 180.ms).fadeIn(),

                              const SizedBox(height: 32),

                              CustomInputField(
                                    controller: _phoneController,
                                    hint: 'Phone number',
                                    icon: Icons.phone_android_rounded,
                                    isDark: isDark,
                                    keyboardType: TextInputType.phone,
                                  )
                                  .animate(delay: 250.ms)
                                  .fadeIn()
                                  .slideY(begin: 0.15, end: 0),

                              const SizedBox(height: 14),

                              CustomInputField(
                                    controller: _passwordController,
                                    hint: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    isDark: isDark,
                                    obscure: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 18,
                                        color: isDark
                                            ? AppColors.textDark.withOpacity(
                                                0.4,
                                              )
                                            : AppColors.textLight.withOpacity(
                                                0.4,
                                              ),
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  )
                                  .animate(delay: 330.ms)
                                  .fadeIn()
                                  .slideY(begin: 0.15, end: 0),

                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationsScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ).animate(delay: 380.ms).fadeIn(),

                              const SizedBox(height: 24),

                              CustomButton(
                                    isLoading: _isLoading,
                                    onTap: _onLogin,
                                    text: 'Login',
                                  )
                                  .animate(delay: 420.ms)
                                  .fadeIn()
                                  .slideY(begin: 0.1, end: 0),

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black12,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'or continue with',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.textDark.withOpacity(
                                                0.4,
                                              )
                                            : AppColors.textLight.withOpacity(
                                                0.4,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black12,
                                    ),
                                  ),
                                ],
                              ).animate(delay: 460.ms).fadeIn(),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  SocialButton(
                                    label: 'Google',
                                    icon: FontAwesomeIcons.google,
                                    iconColor: const Color(0xFFEA4335),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 10),
                                  SocialButton(
                                    label: 'Facebook',
                                    icon: FontAwesomeIcons.facebook,
                                    iconColor: const Color(0xFF1877F2),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 10),
                                  SocialButton(
                                    label: 'Twitter',
                                    icon: FontAwesomeIcons.twitter,
                                    iconColor: isDark
                                        ? Colors.white
                                        : Colors.black,
                                    isDark: isDark,
                                  ),
                                ],
                              ).animate(delay: 500.ms).fadeIn(),

                              const SizedBox(height: 20),

                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.textDark.withOpacity(
                                                0.5,
                                              )
                                            : AppColors.textLight.withOpacity(
                                                0.5,
                                              ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) => const Register(),
                                            ),
                                          ),
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate(delay: 540.ms).fadeIn(),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: 50.ms)
                    .slideY(
                      begin: 0.18,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(duration: 500.ms),
          ),
        ],
      ),
    );
  }
}

// ── Decorative background circle ──────────────────────────────────────────

// ── Theme toggle pill ──────────────────────────────────────────────────────

// ── Login button ──────────────────────────────────────────────────────────

// ── Social button ─────────────────────────────────────────────────────────

// ── Shake widget ──────────────────────────────────────────────────────────

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:library_mobile_app/core/components/custom_button.dart';
import 'package:library_mobile_app/core/components/custom_input_field.dart';
import 'package:library_mobile_app/core/components/decorCircle.dart';
import 'package:library_mobile_app/core/components/shake_widget.dart';
import 'package:library_mobile_app/core/components/social_button.dart';
import 'package:library_mobile_app/core/components/theme_toggle.dart';
import 'package:library_mobile_app/core/constantPage.dart';
import 'package:library_mobile_app/core/theme.dart';

import 'package:library_mobile_app/feature/login/bloc/login_bloc.dart';
import 'package:library_mobile_app/feature/login/bloc/login_event.dart';
import 'package:library_mobile_app/feature/login/bloc/login_state.dart';
import 'package:library_mobile_app/feature/login/presentation/forgetpassword.dart';
import 'package:library_mobile_app/feature/login/repo/login_repository.dart';

import 'package:library_mobile_app/feature/register/presentation/register.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  late LoginBloc _loginBloc;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _shakeKey = GlobalKey<ShakeWidgetState>();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _loginBloc = LoginBloc(repository: LoginRepository());
  }

  @override
  void dispose() {
    _loginBloc.close();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _shakeKey.currentState?.shake();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Please enter your phone number and password'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      return;
    }

    String? fcmToken;

    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Error fetching FCM token from Firebase: $e');
    }

    if (!mounted) return;

    _loginBloc.add(
      LoginSubmitted(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        fcm_token: fcmToken ?? "",
      ),
    );
  }

  void _openForgotPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const Register()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _loginBloc,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            _shakeKey.currentState?.shake();

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
          }

          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacementNamed(Routes.homePage);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.accentLight,
          body: Stack(
            children: [
              // ─────────────────────────────
              // Decorative background
              // ─────────────────────────────
              Positioned(
                top: -70,
                left: -70,
                child: DecorCircle(
                  size: 240,
                  color: AppColors.primary,
                  opacity: isDark ? 0.08 : 0.13,
                ),
              ),

              Positioned(
                top: size.height * 0.18,
                right: -90,
                child: DecorCircle(
                  size: 190,
                  color: AppColors.primary,
                  opacity: isDark ? 0.05 : 0.08,
                ),
              ),

              Positioned(
                top: size.height * 0.38,
                left: size.width * 0.18,
                child: DecorCircle(
                  size: 130,
                  color: AppColors.primary,
                  opacity: isDark ? 0.035 : 0.06,
                ),
              ),

              // ─────────────────────────────
              // Theme toggle
              // ─────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 18,
                child: ThemeToggle(isDark: isDark)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.2, end: 0, duration: 400.ms),
              ),

              // ─────────────────────────────
              // Logo
              // ─────────────────────────────
              Positioned(
                top: size.height * 0.075,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Image.asset(
                          'assets/images/logo.png',
                          width: size.width * 0.32,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 12),

                    Text(
                          'Hibr & Waraq',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        )
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 5),

                    Text(
                      'Your digital library',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                        color: isDark
                            ? AppColors.textDark.withOpacity(0.45)
                            : AppColors.textLight.withOpacity(0.5),
                      ),
                    ).animate(delay: 250.ms).fadeIn(duration: 450.ms),
                  ],
                ),
              ),

              // ─────────────────────────────
              // Login Sheet
              // ─────────────────────────────
              Align(
                alignment: Alignment.bottomCenter,
                child:
                    ShakeWidget(
                          key: _shakeKey,
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxHeight: size.height * 0.76,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.accentDark
                                  : Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(34),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.32 : 0.08,
                                  ),
                                  blurRadius: 35,
                                  spreadRadius: 1,
                                  offset: const Offset(0, -10),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              top: false,
                              child: SingleChildScrollView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: EdgeInsets.fromLTRB(
                                  26,
                                  18,
                                  26,
                                  MediaQuery.of(context).viewInsets.bottom +
                                      MediaQuery.of(context).padding.bottom +
                                      28,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Handle
                                    Center(
                                      child: Container(
                                        width: 42,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.black12,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 26),

                                    // Header
                                    Text(
                                          'Welcome back',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                            color: isDark
                                                ? AppColors.textDark
                                                : AppColors.textLight,
                                          ),
                                        )
                                        .animate(delay: 100.ms)
                                        .fadeIn()
                                        .slideY(begin: 0.15, end: 0),

                                    const SizedBox(height: 6),

                                    Text(
                                      'Sign in to continue to your library',
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
                                    ).animate(delay: 150.ms).fadeIn(),

                                    const SizedBox(height: 28),

                                    // Phone
                                    CustomInputField(
                                          controller: _phoneController,
                                          hint: 'Phone number',
                                          icon: Icons.phone_android_rounded,
                                          isDark: isDark,
                                          keyboardType: TextInputType.phone,
                                        )
                                        .animate(delay: 200.ms)
                                        .fadeIn()
                                        .slideY(begin: 0.12, end: 0),

                                    const SizedBox(height: 14),

                                    // Password
                                    CustomInputField(
                                          controller: _passwordController,
                                          hint: 'Password',
                                          icon: Icons.lock_outline_rounded,
                                          isDark: isDark,
                                          obscure: _obscurePassword,
                                          suffixIcon: IconButton(
                                            splashRadius: 20,
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 19,
                                              color: isDark
                                                  ? AppColors.textDark
                                                        .withOpacity(0.4)
                                                  : AppColors.textLight
                                                        .withOpacity(0.4),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        )
                                        .animate(delay: 270.ms)
                                        .fadeIn()
                                        .slideY(begin: 0.12, end: 0),

                                    const SizedBox(height: 8),

                                    // Forgot password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _openForgotPassword,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 6,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ).animate(delay: 320.ms).fadeIn(),

                                    const SizedBox(height: 18),

                                    // Login button
                                    BlocBuilder<LoginBloc, LoginState>(
                                          builder: (context, state) {
                                            return SizedBox(
                                              width: double.infinity,
                                              child: CustomButton(
                                                isLoading:
                                                    state is LoginLoading,
                                                onTap: _onLogin,
                                                text: 'Login',
                                              ),
                                            );
                                          },
                                        )
                                        .animate(delay: 360.ms)
                                        .fadeIn()
                                        .slideY(begin: 0.1, end: 0),

                                    const SizedBox(height: 24),

                                    // Divider
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
                                                  ? AppColors.textDark
                                                        .withOpacity(0.4)
                                                  : AppColors.textLight
                                                        .withOpacity(0.4),
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
                                    ).animate(delay: 400.ms).fadeIn(),

                                    const SizedBox(height: 16),

                                    // Social
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SocialButton(
                                            label: 'Google',
                                            icon: FontAwesomeIcons.google,
                                            iconColor: const Color(0xFFEA4335),
                                            isDark: isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: SocialButton(
                                            label: 'Facebook',
                                            icon: FontAwesomeIcons.facebook,
                                            iconColor: const Color(0xFF1877F2),
                                            isDark: isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: SocialButton(
                                            label: 'Twitter',
                                            icon: FontAwesomeIcons.twitter,
                                            iconColor: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            isDark: isDark,
                                          ),
                                        ),
                                      ],
                                    ).animate(delay: 440.ms).fadeIn(),

                                    const SizedBox(height: 22),

                                    // Register
                                    Center(
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account? ",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? AppColors.textDark
                                                        .withOpacity(0.5)
                                                  : AppColors.textLight
                                                        .withOpacity(0.5),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _openRegister,
                                            child: const Text(
                                              'Sign up',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate(delay: 480.ms).fadeIn(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate(delay: 50.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 500.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

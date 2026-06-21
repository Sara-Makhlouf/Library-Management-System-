import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:library_mobile_app/core/components/custom_button.dart';
import 'package:library_mobile_app/core/components/decorCircle.dart';
import 'package:library_mobile_app/core/components/shake_widget.dart';
import 'package:library_mobile_app/core/components/social_button.dart';
import 'package:library_mobile_app/core/components/theme_toggle.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/login/login_bloc.dart';
import 'package:library_mobile_app/feature/login/login_event.dart';
import 'package:library_mobile_app/feature/login/login_repository.dart';
import 'package:library_mobile_app/feature/login/login_state.dart';

import 'package:library_mobile_app/feature/notifications/notifications_screen.dart';
import 'package:library_mobile_app/feature/presentation/register.dart';
import 'package:library_mobile_app/core/components/custom_input_field.dart';
// تأكد من إضافة الـ import الصحيح لصفحة الـ HomeScreen هنا، مثلاً:

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  late LoginBloc _loginBloc;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _shakeKey = GlobalKey<ShakeWidgetState>();

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
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _shakeKey.currentState?.shake();
      return;
    }


    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print("Error fetching FCM token From firebase==========================================================================================================================================================================: $e");
    }

    _loginBloc.add(
      LoginSubmitted(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,

        fcm_token: fcmToken ?? "", //هون كان الغلط ...جرب وشوف
      ),
    );
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacementNamed(Routes.homePage);
          }
        },
        child: Scaffold(
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
                    Image.asset(
                          'assets/images/logo.png',
                          width: size.width * 0.40,
                        )
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
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
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
                              color: isDark
                                  ? AppColors.accentDark
                                  : Colors.white,
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
                                          : AppColors.textLight.withOpacity(
                                              0.55,
                                            ),
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
                                                ? AppColors.textDark
                                                      .withOpacity(0.4)
                                                : AppColors.textLight
                                                      .withOpacity(0.4),
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
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
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

                                  BlocBuilder<LoginBloc, LoginState>(
                                    builder: (context, state) {
                                      return CustomButton(
                                        isLoading: state is LoginLoading,
                                        onTap: _onLogin,
                                        text: 'Login',
                                      );
                                    },
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
                                                ? AppColors.textDark
                                                      .withOpacity(0.5)
                                                : AppColors.textLight
                                                      .withOpacity(0.5),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.of(context)
                                              .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const Register(),
                                                ),
                                              ),
                                          child: const Text(
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
        ),
      ),
    );
  }
}

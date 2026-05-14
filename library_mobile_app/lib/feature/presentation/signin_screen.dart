import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/core/theme_cubit.dart';
import 'package:library_mobile_app/feature/presentation/register.dart';

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
  final _shakeKey = GlobalKey<_ShakeWidgetState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            child: _DecorCircle(
              size: 220,
              color: AppColors.primary,
              opacity: isDark ? 0.08 : 0.13,
            ),
          ),
          Positioned(
            top: size.height * 0.15,
            right: -80,
            child: _DecorCircle(
              size: 180,
              color: AppColors.primary,
              opacity: isDark ? 0.05 : 0.09,
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            left: size.width * 0.2,
            child: _DecorCircle(
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
            child: _ThemeToggle(isDark: isDark)
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.3, end: 0),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child:
                _ShakeWidget(
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

                              _InputField(
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

                              _InputField(
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
                                  onPressed: () {},
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

                              _LoginButton(
                                    isLoading: _isLoading,
                                    onTap: _onLogin,
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
                                  _SocialButton(
                                    label: 'Google',
                                    icon: FontAwesomeIcons.google,
                                    iconColor: const Color(0xFFEA4335),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 10),
                                  _SocialButton(
                                    label: 'Facebook',
                                    icon: FontAwesomeIcons.facebook,
                                    iconColor: const Color(0xFF1877F2),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 10),
                                  _SocialButton(
                                    label: 'Apple',
                                    icon: FontAwesomeIcons.apple,
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
class _DecorCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _DecorCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

// ── Theme toggle pill ──────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  const _ThemeToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().toggleTheme(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputDark : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: 5),
            Text(
              isDark ? 'Dark' : 'Light',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      cursorColor: AppColors.primary,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppColors.inputDark : AppColors.backgroundLight,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppColors.textDark.withOpacity(0.35)
              : AppColors.textLight.withOpacity(0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}

// ── Login button ──────────────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoginButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

// ── Social button ─────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final Color iconColor;
  final bool isDark;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.07),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shake widget ──────────────────────────────────────────────────────────
class _ShakeWidget extends StatefulWidget {
  final Widget child;
  const _ShakeWidget({super.key, required this.child});

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  void shake() {
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final dx = _ctrl.isAnimating
            ? 6 *
                  (0.5 - (_anim.value * 6 % 1).abs()).sign *
                  (_anim.value < 0.8 ? 1 : 0)
            : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/presentation/books/book.dart';
import 'package:library_mobile_app/feature/presentation/signin_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _rePassController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _rePassController.dispose();
    super.dispose();
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
            top: size.height * 0.12,
            right: -80,
            child: _DecorCircle(
              size: 180,
              color: AppColors.primary,
              opacity: isDark ? 0.05 : 0.09,
            ),
          ),
          Positioned(
            top: size.height * 0.3,
            left: size.width * 0.2,
            child: _DecorCircle(
              size: 120,
              color: AppColors.primary,
              opacity: isDark ? 0.04 : 0.07,
            ),
          ),

          Positioned(
            top: size.height * 0.06,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: size.width * 0.40)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
                Text(
                  'Hibr & Waraq',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
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

          Align(
            alignment: Alignment.bottomCenter,
            child:
                Container(
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
                          28,
                          28,
                          MediaQuery.of(context).viewInsets.bottom + 28,
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
                            const SizedBox(height: 20),

                            Row(
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.textDark
                                            : AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                )
                                .animate(delay: 100.ms)
                                .fadeIn()
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 4),

                            Text(
                              'Join Hibr & Waraq today',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textDark.withOpacity(0.5)
                                    : AppColors.textLight.withOpacity(0.5),
                              ),
                            ).animate(delay: 160.ms).fadeIn(),

                            const SizedBox(height: 24),

                            Row(
                                  children: [
                                    Expanded(
                                      child: _Field(
                                        controller: _firstNameController,
                                        hint: 'First name',
                                        icon: Icons.person_outline_rounded,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field(
                                        controller: _lastNameController,
                                        hint: 'Last name',
                                        icon: Icons.person_outline_rounded,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                )
                                .animate(delay: 200.ms)
                                .fadeIn()
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 12),

                            _Field(
                                  controller: _phoneController,
                                  hint: 'Phone number',
                                  icon: Icons.phone_android_rounded,
                                  isDark: isDark,
                                  keyboardType: TextInputType.phone,
                                )
                                .animate(delay: 260.ms)
                                .fadeIn()
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 12),

                            _Field(
                                  controller: _passController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  isDark: isDark,
                                  obscure: _obscure1,
                                  onToggleObscure: () =>
                                      setState(() => _obscure1 = !_obscure1),
                                )
                                .animate(delay: 320.ms)
                                .fadeIn()
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 12),

                            _Field(
                                  controller: _rePassController,
                                  hint: 'Confirm password',
                                  icon: Icons.lock_outline_rounded,
                                  isDark: isDark,
                                  obscure: _obscure2,
                                  onToggleObscure: () =>
                                      setState(() => _obscure2 = !_obscure2),
                                )
                                .animate(delay: 380.ms)
                                .fadeIn()
                                .slideY(begin: 0.15, end: 0),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const Book(),
                                      ),
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ).animate(delay: 420.ms).fadeIn(),

                            const SizedBox(height: 20),

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
                                    'or sign up with',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textDark.withOpacity(0.4)
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

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                _SocialBtn(
                                  label: 'Google',
                                  icon: FontAwesomeIcons.google,
                                  iconColor: const Color(0xFFEA4335),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 10),
                                _SocialBtn(
                                  label: 'Facebook',
                                  icon: FontAwesomeIcons.facebook,
                                  iconColor: const Color(0xFF1877F2),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 10),
                                _SocialBtn(
                                  label: 'Apple',
                                  icon: FontAwesomeIcons.apple,
                                  iconColor: isDark
                                      ? Colors.white
                                      : Colors.black,
                                  isDark: isDark,
                                ),
                              ],
                            ).animate(delay: 500.ms).fadeIn(),

                            const SizedBox(height: 16),

                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textDark.withOpacity(0.5)
                                          : AppColors.textLight.withOpacity(
                                              0.5,
                                            ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SigninScreen(),
                                          ),
                                        ),
                                    child: Text(
                                      'Sign in',
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

// ── Decorative circle ─────────────────────────────────────────────────────
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

// ── Input field ───────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool obscure;
  final TextInputType keyboardType;
  final VoidCallback? onToggleObscure;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.onToggleObscure,
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
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.4)
                      : AppColors.textLight.withOpacity(0.4),
                ),
                onPressed: onToggleObscure,
              )
            : null,
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

// ── Social button ─────────────────────────────────────────────────────────
class _SocialBtn extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final Color iconColor;
  final bool isDark;

  const _SocialBtn({
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

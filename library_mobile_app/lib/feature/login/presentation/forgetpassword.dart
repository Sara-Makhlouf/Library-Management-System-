import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:library_mobile_app/core/components/custom_button.dart';
import 'package:library_mobile_app/core/components/custom_input_field.dart';
import 'package:library_mobile_app/core/components/decorCircle.dart';
import 'package:library_mobile_app/core/components/theme_toggle.dart';
import 'package:library_mobile_app/core/constants.dart';
import 'package:library_mobile_app/core/theme.dart';

import 'package:library_mobile_app/feature/login/repo/forgetpassword_repo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  final _otpController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  final ForgotPasswordRepository _repository = ForgotPasswordRepository(
    baseUrl: baseUrl,
  );

  bool _isLoading = false;

  bool _otpSent = false;

  bool _otpVerified = false;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  String? _resetToken;

  static const int _resendWaitSeconds = 60;

  int _resendSeconds = 0;

  Timer? _resendTimer;

  bool get _canResend => !_isLoading && _resendSeconds == 0;

  int get _currentStep => _otpVerified ? 2 : (_otpSent ? 1 : 0);

  void _startResendCountdown() {
    _resendTimer?.cancel();

    setState(() {
      _resendSeconds = _resendWaitSeconds;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSeconds <= 1) {
        timer.cancel();

        setState(() {
          _resendSeconds = 0;
        });
      } else {
        setState(() {
          _resendSeconds -= 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();

    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await _repository.sendOtp(email: email);

      if (!mounted) return;

      setState(() {
        _otpSent = true;
        _isLoading = false;
      });

      _startResendCountdown();

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();

    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showMessage('Please enter the verification code', isError: true);
      return;
    }

    if (otp.length != 6) {
      _showMessage('Verification code must be 6 digits', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _repository.verifyOtp(email: email, otp: otp);

      if (!mounted) return;

      setState(() {
        _resetToken = token;
        _otpVerified = true;
        _isLoading = false;
      });

      _showMessage('Code verified successfully');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    final password = _passwordController.text;

    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please enter your new password', isError: true);

      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters', isError: true);

      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match', isError: true);

      return;
    }

    if (_resetToken == null) {
      _showMessage('Please verify the code first', isError: true);

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await _repository.resetPassword(
        email: email,
        resetToken: _resetToken!,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(message);

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _resendOtp() async {
    _otpController.clear();

    setState(() {
      _otpVerified = false;
      _resetToken = null;
    });

    await _sendOtp();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : AppColors.primary,
        ),
      );
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
            top: size.height * 0.18,
            right: -80,
            child: DecorCircle(
              size: 180,
              color: AppColors.primary,
              opacity: isDark ? 0.05 : 0.09,
            ),
          ),

          Positioned(
            top: size.height * 0.38,
            left: size.width * 0.2,
            child: DecorCircle(
              size: 120,
              color: AppColors.primary,
              opacity: isDark ? 0.04 : 0.07,
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: ThemeToggle(
              isDark: isDark,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.3, end: 0),
          ),

          Positioned(
            top: size.height * 0.07,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: size.width * 0.32)
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
                ),

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
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,

            child: Container(
              width: double.infinity,

              constraints: BoxConstraints(maxHeight: size.height * 0.70),

              decoration: BoxDecoration(
                color: isDark ? AppColors.accentDark : Colors.white,

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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
                  MediaQuery.of(context).viewInsets.bottom + 35,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),

                      padding: EdgeInsets.zero,

                      constraints: const BoxConstraints(),

                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 19,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                          key: ValueKey('step_icon_$_currentStep'),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(
                              isDark ? 0.16 : 0.11,
                            ),
                          ),
                          child: Icon(
                            _otpVerified
                                ? Icons.lock_reset_rounded
                                : _otpSent
                                ? Icons.mark_email_read
                                : Icons.email_outlined,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        )
                        .animate(key: ValueKey('step_anim_$_currentStep'))
                        .fadeIn(duration: 300.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 300.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 16),

                    Text(
                          _otpVerified
                              ? 'Create new password'
                              : _otpSent
                              ? 'Verify your email'
                              : 'Forgot password?',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        )
                        .animate(key: ValueKey('step_title_$_currentStep'))
                        .fadeIn()
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 6),

                    Text(
                      _otpVerified
                          ? 'Enter your new password below.'
                          : _otpSent
                          ? 'Enter the code sent to your email.'
                          : 'Enter your email and we will send you a verification code.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textDark.withOpacity(0.55)
                            : AppColors.textLight.withOpacity(0.55),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: List.generate(3, (index) {
                        final active = index <= _currentStep;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 5,
                            width: index == _currentStep ? 26 : 14,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: active
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.15),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    if (!_otpVerified)
                      CustomInputField(
                        controller: _emailController,
                        hint: 'Email address',
                        icon: Icons.email_outlined,
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,
                      ),

                    if (_otpSent && !_otpVerified) ...[
                      const SizedBox(height: 14),

                      CustomInputField(
                        controller: _otpController,
                        hint: '6-digit OTP',
                        icon: Icons.sms_outlined,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: _canResend
                            ? TextButton(
                                onPressed: _resendOtp,
                                child: const Text(
                                  'Resend code',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Resend code in ${_resendSeconds}s',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textDark.withOpacity(0.45)
                                        : AppColors.textLight.withOpacity(0.45),
                                  ),
                                ),
                              ),
                      ),
                    ],

                    if (_otpVerified) ...[
                      CustomInputField(
                        controller: _passwordController,
                        hint: 'New password',
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
                                ? AppColors.textDark.withOpacity(0.4)
                                : AppColors.textLight.withOpacity(0.4),
                          ),

                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      CustomInputField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm new password',
                        icon: Icons.lock_reset_rounded,
                        isDark: isDark,
                        obscure: _obscureConfirmPassword,

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: isDark
                                ? AppColors.textDark.withOpacity(0.4)
                                : AppColors.textLight.withOpacity(0.4),
                          ),

                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    CustomButton(
                      isLoading: _isLoading,

                      onTap: _otpVerified
                          ? _resetPassword
                          : _otpSent
                          ? _verifyOtp
                          : _sendOtp,

                      text: _otpVerified
                          ? 'Reset password'
                          : _otpSent
                          ? 'Verify code'
                          : 'Send OTP',
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),

                        child: const Text(
                          'Back to login',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

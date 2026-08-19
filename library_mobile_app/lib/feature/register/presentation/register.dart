import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:library_mobile_app/core/components/custom_button.dart';
import 'package:library_mobile_app/core/components/decorCircle.dart';
import 'package:library_mobile_app/core/components/shake_widget.dart';
import 'package:library_mobile_app/core/components/social_button.dart';
import 'package:library_mobile_app/core/components/theme_toggle.dart';
import 'package:library_mobile_app/core/components/custom_input_field.dart';
import 'package:library_mobile_app/core/theme.dart';

import 'package:library_mobile_app/feature/login/presentation/signin_screen.dart';
import 'package:library_mobile_app/feature/profile/data/customer_repository.dart';

import 'package:library_mobile_app/feature/register/bloc/register_bloc.dart';
import 'package:library_mobile_app/feature/register/data/register_repository.dart';
import 'package:library_mobile_app/feature/register/helper/dots.dart';
import 'package:library_mobile_app/feature/register/helper/gender.dart';
import 'package:library_mobile_app/feature/register/presentation/otp_page.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _rePassController = TextEditingController();

  final _shakeKey = GlobalKey<ShakeWidgetState>();

  late RegisterBloc _registerBloc;
  late RegisterRepository _registerRepository;
  late CustomerRepository _customerRepository;

  int _currentStep = 0;

  String _gender = 'M';

  bool _obscure1 = true;
  bool _obscure2 = true;

  bool _sendingOtp = false;

  @override
  void initState() {
    super.initState();

    _registerRepository = RegisterRepository();
    _customerRepository = CustomerRepository();

    _registerBloc = RegisterBloc(
      repository: _registerRepository,
      customerRepository: _customerRepository,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _rePassController.dispose();

    _registerBloc.close();

    super.dispose();
  }

 
  Future<void> _pickDob() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.accentDark : Colors.white,
              onSurface: isDark ? AppColors.textDark : AppColors.textLight,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-'
            '${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

 
  String _normalizePhone(String phone) {
    phone = phone
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    // +963934426849
    if (phone.startsWith('+963')) {
      phone = '0${phone.substring(4)}';
    }
    // 00963934426849
    else if (phone.startsWith('00963')) {
      phone = '0${phone.substring(5)}';
    }
    // 963934426849
    else if (phone.startsWith('963')) {
      phone = '0${phone.substring(3)}';
    }

    return phone;
  }

 
  bool _isValidSyrianPhone(String phone) {
    final normalized = _normalizePhone(phone);

    if (normalized.length != 10) {
      return false;
    }

    if (!normalized.startsWith('09')) {
      return false;
    }

   

    return RegExp(r'^09[0-9]{8}$').hasMatch(normalized);
  }

 
  void _goNext() {
    final name = _fullNameController.text.trim();
    final dob = _dobController.text.trim();
    final rawPhone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    if (dob.isEmpty) {
      _showError('Please select your date of birth');
      return;
    }

    if (rawPhone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    final phone = _normalizePhone(rawPhone);

    if (!_isValidSyrianPhone(phone)) {
      _showError(
        'Please enter a valid Syrian phone number\n'
        'Example: 0934426849',
      );
      return;
    }

    _phoneController.text = phone;

    setState(() {
      _currentStep = 1;
    });
  }

 
  void _goBack() {
    if (_sendingOtp) return;

    setState(() {
      _currentStep = 0;
    });
  }

  
  String? _validatePasswords() {
    final pass = _passController.text;
    final rePass = _rePassController.text;

    if (pass.isEmpty) {
      return 'Please enter your password';
    }

    if (pass.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (rePass.isEmpty) {
      return 'Please confirm your password';
    }

    if (pass != rePass) {
      return 'Passwords do not match';
    }

    return null;
  }


  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return emailRegex.hasMatch(email);
  }


  void _showError(String message) {
    if (!mounted) return;

    _shakeKey.currentState?.shake();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

 
  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

 
  Future<void> _onCreateAccount() async {
    if (_sendingOtp) return;

    final email = _emailController.text.trim();

    final phone = _normalizePhone(_phoneController.text);

  
    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email');
      return;
    }

   
    final passwordError = _validatePasswords();

    if (passwordError != null) {
      _showError(passwordError);
      return;
    }

  
    if (!_isValidSyrianPhone(phone)) {
      _showError(
        'Please enter a valid Syrian phone number\n'
        'Example: 0934426849',
      );
      return;
    }

 
    _phoneController.text = phone;

  
    final registerData = <String, dynamic>{
      'name': _fullNameController.text.trim(),
      'email': email,
      'password': _passController.text,
      'password_confirmation': _rePassController.text,
      'gender': _gender,
      'phone': phone,
      'DOB': _dobController.text.trim(),
      'lang': 'ar',
      'fcm_token': '',
    };

    debugPrint('================================');
    debugPrint('REGISTER DATA');
    debugPrint(registerData.toString());
    debugPrint('PHONE: $phone');
    debugPrint('================================');

    setState(() {
      _sendingOtp = true;
    });

    try {
   
      final result = await _registerRepository.sendOtp(phone: phone);

      debugPrint('🟢 OTP RESPONSE: $result');

      if (!mounted) return;

      _showSuccess('Verification code sent to your WhatsApp');

    
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return OtpPage(
              phone: phone,
              registerData: registerData,
              registerBloc: _registerBloc,
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('🔴 SEND OTP FAILED: $e');

      if (!mounted) return;

      String message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      _showError(message);
    } finally {
      if (mounted) {
        setState(() {
          _sendingOtp = false;
        });
      }
    }
  }

 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _registerBloc,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.accentLight,
        appBar: AppBar(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.accentLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () {
              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const SigninScreen(),
                                                ),
                                              );
            },
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 300.ms),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: ThemeToggle(isDark: isDark)
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.3, end: 0),
              ),
            ),
          ],
        ),
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
              top: size.height * 0.12,
              right: -80,
              child: DecorCircle(
                size: 180,
                color: AppColors.primary,
                opacity: isDark ? 0.05 : 0.09,
              ),
            ),

            Positioned(
              top: size.height * 0.3,
              left: size.width * 0.2,
              child: DecorCircle(
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
                  Image.asset(
                        'assets/images/logo.png',
                        width: size.width * 0.40,
                      )
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
                              28,
                              28,
                              MediaQuery.of(context).viewInsets.bottom +
                                  MediaQuery.of(context).padding.bottom +
                                  40,
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

                                StepDots(
                                  currentStep: _currentStep,
                                  isDark: isDark,
                                ).animate(delay: 80.ms).fadeIn(),

                                const SizedBox(height: 16),

                                Text(
                                      _currentStep == 0
                                          ? 'Personal info'
                                          : 'Account security',
                                      style: TextStyle(
                                        fontSize: 22,
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
                                  _currentStep == 0
                                      ? 'Step 1 of 2'
                                      : 'Step 2 of 2',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textDark.withOpacity(0.5)
                                        : AppColors.textLight.withOpacity(0.5),
                                  ),
                                ).animate(delay: 160.ms).fadeIn(),

                                const SizedBox(height: 24),

                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: _currentStep == 0
                                      ? _buildStepOne(isDark)
                                      : _buildStepTwo(isDark),
                                ),
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
    );
  }


  Widget _buildStepOne(bool isDark) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          controller: _fullNameController,
          hint: 'Full name',
          icon: Icons.person_outline_rounded,
          isDark: isDark,
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15, end: 0),

        const SizedBox(height: 12),

        GestureDetector(
          onTap: _pickDob,
          child: AbsorbPointer(
            child: CustomInputField(
              controller: _dobController,
              hint: 'Date of birth',
              icon: Icons.calendar_today_outlined,
              isDark: isDark,
            ),
          ),
        ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.15, end: 0),

        const SizedBox(height: 12),

        GenderSelector(
          selected: _gender,
          isDark: isDark,
          onChanged: (g) {
            setState(() {
              _gender = g;
            });
          },
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15, end: 0),

        const SizedBox(height: 12),

        CustomInputField(
          controller: _phoneController,
          hint: 'Phone number (09xxxxxxxx)',
          icon: Icons.phone_android_rounded,
          isDark: isDark,
          keyboardType: TextInputType.phone,
        ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.15, end: 0),

        const SizedBox(height: 24),

        CustomButton(
          isLoading: false,
          onTap: _goNext,
          text: 'Next',
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  
  Widget _buildStepTwo(bool isDark) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.email_outlined,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15, end: 0),

        const SizedBox(height: 12),

        CustomInputField(
          controller: _passController,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          obscure: _obscure1,
          suffixIcon: IconButton(
            icon: Icon(
              _obscure1
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.4)
                  : AppColors.textLight.withOpacity(0.4),
            ),
            onPressed: () {
              setState(() {
                _obscure1 = !_obscure1;
              });
            },
          ),
        ).animate(delay: 260.ms).fadeIn().slideY(begin: 0.15, end: 0),

        const SizedBox(height: 12),

        CustomInputField(
          controller: _rePassController,
          hint: 'Confirm password',
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          obscure: _obscure2,
          suffixIcon: IconButton(
            icon: Icon(
              _obscure2
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: isDark
                  ? AppColors.textDark.withOpacity(0.4)
                  : AppColors.textLight.withOpacity(0.4),
            ),
            onPressed: () {
              setState(() {
                _obscure2 = !_obscure2;
              });
            },
          ),
        ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.15, end: 0),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _sendingOtp ? null : _goBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: CustomButton(
                isLoading: _sendingOtp,
                onTap: _sendingOtp ? () {} : _onCreateAccount,
                text: 'Continue',
              ),
            ),
          ],
        ).animate(delay: 380.ms).fadeIn(),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: Divider(color: isDark ? Colors.white12 : Colors.black12),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or sign up with',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.4)
                      : AppColors.textLight.withOpacity(0.4),
                ),
              ),
            ),

            Expanded(
              child: Divider(color: isDark ? Colors.white12 : Colors.black12),
            ),
          ],
        ).animate(delay: 420.ms).fadeIn(),

        const SizedBox(height: 14),

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
              iconColor: isDark ? Colors.white : Colors.black,
              isDark: isDark,
            ),
          ],
        ).animate(delay: 460.ms).fadeIn(),

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
                      : AppColors.textLight.withOpacity(0.5),
                ),
              ),

              GestureDetector(
                onTap: _sendingOtp
                    ? null
                    : () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SigninScreen(),
                          ),
                        );
                      },
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
        ).animate(delay: 500.ms).fadeIn(),
      ],
    );
  }
}

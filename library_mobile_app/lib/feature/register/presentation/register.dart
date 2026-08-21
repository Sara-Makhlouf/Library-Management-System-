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

  // ------------------------------------------------------------
  // DATE OF BIRTH
  // ------------------------------------------------------------

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
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.primary,
              onSecondary: Colors.white,
              surface: isDark ? AppColors.accentDark : Colors.white,
              onSurface: isDark ? AppColors.textDark : AppColors.textLight,
              error: Colors.red,
              onError: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _dobController.text =
          '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  // ------------------------------------------------------------
  // PHONE
  // ------------------------------------------------------------

  String _normalizePhone(String phone) {
    phone = phone
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    if (phone.startsWith('+963')) {
      phone = '0${phone.substring(4)}';
    } else if (phone.startsWith('00963')) {
      phone = '0${phone.substring(5)}';
    } else if (phone.startsWith('963')) {
      phone = '0${phone.substring(3)}';
    }

    return phone;
  }

  bool _isValidSyrianPhone(String phone) {
    final normalized = _normalizePhone(phone);

    return RegExp(r'^09[0-9]{8}$').hasMatch(normalized);
  }

  // ------------------------------------------------------------
  // EMAIL
  // ------------------------------------------------------------

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // ------------------------------------------------------------
  // STEP ONE
  // ------------------------------------------------------------

  void _goNext() {
    final name = _fullNameController.text.trim();
    final dob = _dobController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    if (name.length < 3) {
      _showError('Please enter a valid full name');
      return;
    }

    if (dob.isEmpty) {
      _showError('Please select your date of birth');
      return;
    }

    if (!_isValidSyrianPhone(phone)) {
      _showError(
        'Please enter a valid Syrian phone number\n'
        'Example: 0934426849',
      );
      return;
    }

    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _currentStep = 1;
    });
  }

  // ------------------------------------------------------------
  // BACK
  // ------------------------------------------------------------

  void _goBack() {
    if (_sendingOtp) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _currentStep = 0;
    });
  }

  // ------------------------------------------------------------
  // PASSWORD VALIDATION
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  void _showError(String message) {
    if (!mounted) return;

    _shakeKey.currentState?.shake();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ------------------------------------------------------------
  // SUCCESS
  // ------------------------------------------------------------

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ------------------------------------------------------------
  // CREATE ACCOUNT
  // ------------------------------------------------------------

  Future<void> _onCreateAccount() async {
    if (_sendingOtp) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    final phone = _normalizePhone(_phoneController.text.trim());

    if (!_isValidSyrianPhone(phone)) {
      _showError(
        'Please enter a valid Syrian phone number\n'
        'Example: 0934426849',
      );
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

    String? fcmToken;

    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
    }

    final registerData = <String, dynamic>{
      'name': _fullNameController.text.trim(),
      'email': email,
      'phone': phone,
      'password': _passController.text,
      'password_confirmation': _rePassController.text,
      'gender': _gender,
      'DOB': _dobController.text.trim(),
      'lang': 'ar',
      'fcm_token': fcmToken,
    };

    debugPrint('================================');
    debugPrint('REGISTER DATA');
    debugPrint(registerData.toString());
    debugPrint('================================');

    setState(() {
      _sendingOtp = true;
    });

    try {
      final result = await _registerRepository.sendOtp(email: email);

      debugPrint('🟢 OTP RESPONSE: $result');

      if (!mounted) return;

      _showSuccess('Verification code sent to your email');

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpPage(
            email: email,
            registerData: registerData,
            registerBloc: _registerBloc,
          ),
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

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            color: AppColors.primary,
            onPressed: _sendingOtp
                ? null
                : () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SigninScreen()),
                    );
                  },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ThemeToggle(isDark: isDark),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -80,
              left: -80,
              child: DecorCircle(
                size: 240,
                color: AppColors.primary,
                opacity: isDark ? 0.07 : 0.12,
              ),
            ),

            Positioned(
              top: size.height * .15,
              right: -90,
              child: DecorCircle(
                size: 190,
                color: AppColors.primary,
                opacity: isDark ? 0.045 : 0.08,
              ),
            ),

            Positioned(
              top: size.height * .40,
              left: size.width * .15,
              child: DecorCircle(
                size: 120,
                color: AppColors.primary,
                opacity: isDark ? 0.03 : 0.055,
              ),
            ),

            // Header
            Positioned(
              top: 5,
              left: 0,
              right: 0,
              child: _buildHeader(size, isDark),
            ),

            // Bottom card
            Align(
              alignment: Alignment.bottomCenter,
              child:
                  ShakeWidget(
                        key: _shakeKey,
                        child: _buildFormCard(size, isDark),
                      )
                      .animate(delay: 50.ms)
                      .slideY(
                        begin: .15,
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

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(Size size, bool isDark) {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', width: size.width * .32)
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(.85, .85),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 8),

        Text(
          'Hibr & Waraq',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ).animate(delay: 120.ms).fadeIn(),

        const SizedBox(height: 3),

        Text(
          'Create your digital library account',
          style: TextStyle(
            fontSize: 11.5,
            letterSpacing: .2,
            color: isDark
                ? AppColors.textDark.withOpacity(.45)
                : AppColors.textLight.withOpacity(.5),
          ),
        ).animate(delay: 200.ms).fadeIn(),
      ],
    );
  }

  // ------------------------------------------------------------
  // FORM CARD
  // ------------------------------------------------------------

  Widget _buildFormCard(Size size, bool isDark) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: size.height * .68),
      decoration: BoxDecoration(
        color: isDark ? AppColors.accentDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .28 : .07),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          28,
          22,
          28,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Step indicator
            Row(
              children: [
                Expanded(child: _buildStepProgress(isDark)),
                const SizedBox(width: 14),
                Text(
                  '${_currentStep + 1}/2',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
                  _currentStep == 0
                      ? 'Create your account'
                      : 'Secure your account',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                )
                .animate(key: ValueKey('title$_currentStep'))
                .fadeIn()
                .slideY(begin: .15, end: 0),

            const SizedBox(height: 5),

            Text(
              _currentStep == 0
                  ? 'Tell us a little about yourself'
                  : 'Choose a strong password for your account',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark
                    ? AppColors.textDark.withOpacity(.48)
                    : AppColors.textLight.withOpacity(.5),
              ),
            ),

            const SizedBox(height: 22),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _currentStep == 0
                  ? _buildStepOne(isDark)
                  : _buildStepTwo(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROGRESS
  // ------------------------------------------------------------

  Widget _buildStepProgress(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 5,
            decoration: BoxDecoration(
              color: _currentStep == 1
                  ? AppColors.primary
                  : (isDark ? Colors.white12 : Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STEP ONE
  // ------------------------------------------------------------

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
        ).animate(delay: 80.ms).fadeIn().slideY(begin: .12, end: 0),

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
        ).animate(delay: 120.ms).fadeIn().slideY(begin: .12, end: 0),

        const SizedBox(height: 12),

        CustomInputField(
          controller: _phoneController,
          hint: 'Phone number',
          icon: Icons.phone_outlined,
          isDark: isDark,
          keyboardType: TextInputType.phone,
        ).animate(delay: 160.ms).fadeIn().slideY(begin: .12, end: 0),

        const SizedBox(height: 12),

        GenderSelector(
          selected: _gender,
          isDark: isDark,
          onChanged: (gender) {
            setState(() {
              _gender = gender;
            });
          },
        ).animate(delay: 200.ms).fadeIn().slideY(begin: .12, end: 0),

        const SizedBox(height: 12),

        CustomInputField(
          controller: _emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
        ).animate(delay: 240.ms).fadeIn().slideY(begin: .12, end: 0),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          child: CustomButton(
            isLoading: false,
            onTap: _goNext,
            text: 'Continue',
          ),
        ).animate(delay: 280.ms).fadeIn().slideY(begin: .08, end: 0),

        const SizedBox(height: 18),

        _buildLoginLink(isDark),
      ],
    );
  }

  // ------------------------------------------------------------
  // STEP TWO
  // ------------------------------------------------------------

  Widget _buildStepTwo(bool isDark) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          controller: _passController,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          obscure: _obscure1,
          suffixIcon: IconButton(
            splashRadius: 20,
            icon: Icon(
              _obscure1
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: isDark
                  ? AppColors.textDark.withOpacity(.4)
                  : AppColors.textLight.withOpacity(.4),
            ),
            onPressed: () {
              setState(() {
                _obscure1 = !_obscure1;
              });
            },
          ),
        ).animate(delay: 80.ms).fadeIn().slideY(begin: .12, end: 0),

        const SizedBox(height: 12),

        CustomInputField(
          controller: _rePassController,
          hint: 'Confirm password',
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          obscure: _obscure2,
          suffixIcon: IconButton(
            splashRadius: 20,
            icon: Icon(
              _obscure2
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: isDark
                  ? AppColors.textDark.withOpacity(.4)
                  : AppColors.textLight.withOpacity(.4),
            ),
            onPressed: () {
              setState(() {
                _obscure2 = !_obscure2;
              });
            },
          ),
        ).animate(delay: 120.ms).fadeIn().slideY(begin: .12, end: 0),

        const SizedBox(height: 16),

        _buildPasswordHint(isDark),

        const SizedBox(height: 22),

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
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: CustomButton(
                isLoading: _sendingOtp,
                onTap: _sendingOtp ? () {} : _onCreateAccount,
                text: 'Create account',
              ),
            ),
          ],
        ).animate(delay: 200.ms).fadeIn().slideY(begin: .08, end: 0),

        const SizedBox(height: 22),

        _buildDivider(isDark),

        const SizedBox(height: 14),

        _buildSocialButtons(isDark),

        const SizedBox(height: 18),

        _buildLoginLink(isDark),
      ],
    );
  }

  // ------------------------------------------------------------
  // PASSWORD HINT
  // ------------------------------------------------------------

  Widget _buildPasswordHint(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(.035)
            : AppColors.backgroundLight.withOpacity(.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.05)
              : Colors.black.withOpacity(.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 17, color: AppColors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Use at least 8 characters for a stronger password.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: isDark
                    ? AppColors.textDark.withOpacity(.5)
                    : AppColors.textLight.withOpacity(.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DIVIDER
  // ------------------------------------------------------------

  Widget _buildDivider(bool isDark) {
    return Row(
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
                  ? AppColors.textDark.withOpacity(.4)
                  : AppColors.textLight.withOpacity(.4),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SOCIAL BUTTONS
  // ------------------------------------------------------------

  Widget _buildSocialButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            label: 'Google',
            icon: FontAwesomeIcons.google,
            iconColor: const Color(0xFFEA4335),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SocialButton(
            label: 'Facebook',
            icon: FontAwesomeIcons.facebook,
            iconColor: const Color(0xFF1877F2),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SocialButton(
            label: 'Twitter',
            icon: FontAwesomeIcons.twitter,
            iconColor: isDark ? Colors.white : Colors.black,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // LOGIN LINK
  // ------------------------------------------------------------

  Widget _buildLoginLink(bool isDark) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark
                  ? AppColors.textDark.withOpacity(.48)
                  : AppColors.textLight.withOpacity(.5),
            ),
          ),
          GestureDetector(
            onTap: _sendingOtp
                ? null
                : () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SigninScreen()),
                    );
                  },
            child: Text(
              'Sign in',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

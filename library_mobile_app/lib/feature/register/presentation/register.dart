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
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/feature/login/presentation/signin_screen.dart';
import 'package:library_mobile_app/feature/register/bloc/register_bloc.dart';
import 'package:library_mobile_app/feature/register/bloc/register_event.dart';
import 'package:library_mobile_app/feature/register/bloc/register_state.dart';
import 'package:library_mobile_app/feature/register/data/register_repository.dart';

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

  int _currentStep = 0;
  String _gender = 'M';
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    _registerBloc = RegisterBloc(repository: RegisterRepository());
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
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _goNext() {
    if (_fullNameController.text.trim().isEmpty ||
        _dobController.text.isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _shakeKey.currentState?.shake();
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _goBack() {
    setState(() => _currentStep = 0);
  }

  String? _validatePasswords() {
    final pass = _passController.text;
    final rePass = _rePassController.text;

    if (pass.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (pass != rePass) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _showError(String message) {
    _shakeKey.currentState?.shake();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onCreateAccount() {
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    final passwordError = _validatePasswords();
    if (passwordError != null) {
      _showError(passwordError);
      return;
    }

    print('🟡 Create account button pressed, dispatching RegisterSubmitted');

    _registerBloc.add(
      RegisterSubmitted(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passController.text,
        passwordConfirmation: _rePassController.text,
        gender: _gender,
        phone: _phoneController.text.trim(),
        dob: _dobController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _registerBloc,
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacementNamed(Routes.homePage);
          } else if (state is RegisterFailure) {
            _showError(state.message);
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
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
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
                                  _StepDots(
                                    currentStep: _currentStep,
                                    isDark: isDark,
                                  ).animate(delay: 80.ms).fadeIn(),
                                  const SizedBox(height: 16),
                                  Row(
                                        children: [
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
                                          ),
                                        ],
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
                                          : AppColors.textLight.withOpacity(
                                              0.5,
                                            ),
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
        _GenderSelector(
          selected: _gender,
          isDark: isDark,
          onChanged: (g) => setState(() => _gender = g),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15, end: 0),
        const SizedBox(height: 12),
        CustomInputField(
          controller: _phoneController,
          hint: 'Phone number',
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
            onPressed: () => setState(() => _obscure1 = !_obscure1),
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
            onPressed: () => setState(() => _obscure2 = !_obscure2),
          ),
        ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.15, end: 0),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _goBack,
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
              child: BlocBuilder<RegisterBloc, RegisterState>(
                builder: (context, state) {
                  return CustomButton(
                    isLoading: state is RegisterLoading,
                    onTap: _onCreateAccount,
                    text: 'Create account',
                  );
                },
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
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SigninScreen()),
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
        ).animate(delay: 500.ms).fadeIn(),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  final int currentStep;
  final bool isDark;
  const _StepDots({required this.currentStep, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) => Container(
      width: 26,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : (isDark ? Colors.white12 : Colors.black12),
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [dot(currentStep >= 0), dot(currentStep >= 1)],
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;
  const _GenderSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  Widget _chip(String value, String label, IconData icon) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : (isDark ? AppColors.inputDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textDark.withOpacity(0.5)
                          : AppColors.textLight.withOpacity(0.5)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.textDark : AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('M', 'Male', Icons.male_rounded),
        const SizedBox(width: 10),
        _chip('F', 'Female', Icons.female_rounded),
      ],
    );
  }
}

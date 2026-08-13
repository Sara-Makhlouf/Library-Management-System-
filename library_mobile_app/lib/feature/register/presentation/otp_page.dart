import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/feature/register/bloc/register_bloc.dart';
import 'package:library_mobile_app/feature/register/bloc/register_event.dart';
import 'package:library_mobile_app/feature/register/bloc/register_state.dart';
import 'package:library_mobile_app/feature/register/data/register_repository.dart';
import 'package:library_mobile_app/feature/register/helper/colors.dart';
import 'package:library_mobile_app/feature/register/widgets/buildicon.dart';
import 'package:library_mobile_app/feature/register/widgets/buildtitleblock.dart';

class OtpPage extends StatefulWidget {
  final String phone;

  final Map<String, dynamic> registerData;

  final RegisterBloc registerBloc;

  const OtpPage({
    super.key,
    required this.phone,
    required this.registerData,
    required this.registerBloc,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  void dispose() {
    _countdownTimer?.cancel();

    otpController.dispose();

    otpFocusNode.dispose();

    super.dispose();
  }

  static const int otpLength = 6;

  static const int resendSeconds = 60;

  final TextEditingController otpController = TextEditingController();

  final FocusNode otpFocusNode = FocusNode();

  final RegisterRepository _repository = RegisterRepository();

  bool loading = false;

  bool sendingOtp = false;

  int secondsLeft = 0;

  Timer? _countdownTimer;

  bool get canResend => !loading && !sendingOtp && secondsLeft == 0;

  @override
  void initState() {
    super.initState();

    otpController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _sendOtp();
  }

  Future<void> _sendOtp() async {
    if (sendingOtp) return;

    setState(() {
      sendingOtp = true;
    });

    try {
      final result = await _repository.sendOtp(phone: widget.phone);

      debugPrint('🟢 OTP Response: $result');

      if (!mounted) return;

      setState(() {
        sendingOtp = false;
      });

      _startCountdown();

      _showSuccess(
        result['message']?.toString() ?? 'Verification code sent to WhatsApp',
      );
    } catch (e) {
      debugPrint('🔴 WhatsApp OTP Error: $e');

      if (!mounted) return;

      setState(() {
        sendingOtp = false;
        loading = false;
      });

      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != otpLength) {
      _showError('Please enter the 6-digit verification code');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await _repository.verifyOtp(phone: widget.phone, otp: otp);

      debugPrint('🟢 OTP verified');
      debugPrint('🟢 Response: $result');

      if (!mounted) return;

      _showSuccess(
        result['message']?.toString() ?? 'Phone verified successfully',
      );

      widget.registerBloc.add(
        RegisterSubmitted(
          name: widget.registerData['name'],
          email: widget.registerData['email'],
          password: widget.registerData['password'],
          passwordConfirmation: widget.registerData['password_confirmation'],
          gender: widget.registerData['gender'],
          phone: widget.registerData['phone'],
          dob: widget.registerData['DOB'],
          lang: widget.registerData['lang'] ?? 'ar',
          fcmToken: widget.registerData['fcm_token'] ?? '',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    setState(() {
      secondsLeft = resendSeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (secondsLeft <= 1) {
        timer.cancel();

        setState(() {
          secondsLeft = 0;
        });
      } else {
        setState(() {
          secondsLeft -= 1;
        });
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: OtpColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: OtpColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      bloc: widget.registerBloc,
      listener: (context, state) {
        if (state is RegisterLoading) {
          if (!mounted) return;

          setState(() {
            loading = true;
          });
        } else if (state is RegisterSuccess) {
          if (!mounted) return;

          setState(() {
            loading = false;
          });

          _showSuccess('Account created successfully 🎉');

          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (state is RegisterFailure) {
          if (!mounted) return;

          setState(() {
            loading = false;
          });

          _showError(state.message);
        }
      },

      child: Scaffold(
        backgroundColor: OtpColors.bgTop,
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: OtpColors.ink),
          title: const Text(
            'Verify phone number',
            style: TextStyle(color: OtpColors.ink, fontWeight: FontWeight.w600),
          ),
        ),

        body: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [OtpColors.bgTop, OtpColors.bgBottom],
            ),
          ),

          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),

                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const SizedBox(height: 16),

                          buildIcon(),

                          const SizedBox(height: 28),

                          buildTitleBlock(),

                          const SizedBox(height: 36),

                          _buildOtpBoxes(),

                          const SizedBox(height: 28),

                          _buildVerifyButton(),

                          const SizedBox(height: 18),

                          _buildResendRow(),

                          const Spacer(),

                          _buildFooterNote(),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBoxes() {
    final value = otpController.text;

    return GestureDetector(
      onTap: () {
        otpFocusNode.requestFocus();
      },

      child: Stack(
        alignment: Alignment.center,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: List.generate(otpLength, (index) {
              final filled = index < value.length;

              final isCurrent = index == value.length && otpFocusNode.hasFocus;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),

                margin: const EdgeInsets.symmetric(horizontal: 5),

                width: 46,
                height: 56,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(
                    color: isCurrent
                        ? OtpColors.primaryStart
                        : filled
                        ? OtpColors.primaryEnd.withOpacity(0.6)
                        : OtpColors.boxBorder,
                    width: isCurrent ? 2 : 1.4,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Text(
                  filled ? value[index] : '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: OtpColors.ink,
                  ),
                ),
              );
            }),
          ),

          Opacity(
            opacity: 0,

            child: SizedBox(
              width: double.infinity,
              height: 56,

              child: TextField(
                controller: otpController,
                focusNode: otpFocusNode,

                keyboardType: TextInputType.number,

                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,

                  LengthLimitingTextInputFormatter(otpLength),
                ],

                onChanged: (_) {
                  if (otpController.text.length == otpLength) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          gradient: LinearGradient(
            colors: loading
                ? [Colors.grey.shade400, Colors.grey.shade400]
                : const [OtpColors.primaryStart, OtpColors.primaryEnd],
          ),

          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                    color: OtpColors.primaryStart.withOpacity(0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),

        child: ElevatedButton(
          onPressed: loading ? null : _verifyOtp,

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          child: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,

                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Verify & create account',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    if (sendingOtp) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          SizedBox(
            width: 16,
            height: 16,

            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: OtpColors.primaryStart,
            ),
          ),

          SizedBox(width: 10),

          Text(
            'Sending code...',
            style: TextStyle(color: OtpColors.inkMuted, fontSize: 14),
          ),
        ],
      );
    }

    if (!canResend) {
      return Text(
        'Resend code in ${secondsLeft}s',

        style: const TextStyle(color: OtpColors.inkMuted, fontSize: 14),
      );
    }

    return TextButton(
      onPressed: _sendOtp,

      style: TextButton.styleFrom(foregroundColor: OtpColors.primaryStart),

      child: const Text(
        'Resend verification code',

        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: OtpColors.inkMuted.withOpacity(0.8),
        ),

        const SizedBox(width: 6),

        Text(
          'Your number is used only to verify your account',

          style: TextStyle(
            fontSize: 12,
            color: OtpColors.inkMuted.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

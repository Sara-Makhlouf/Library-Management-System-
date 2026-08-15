import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/core/components/custom_button.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/presentation/screens/home_page.dart';

import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../data/register_repository.dart';

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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final RegisterRepository _repository = RegisterRepository();

  bool _sendingOtp = false;

  bool _verifying = false;

  int _seconds = 60;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _startTimer();

    // إرسال OTP مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_sendingOtp) return;

    setState(() {
      _sendingOtp = true;
    });

    try {
      final result = await _repository.sendOtp(phone: widget.phone);

      debugPrint('🟢 OTP RESPONSE: $result');

      if (!mounted) return;

      _showMessage(
        result['message']?.toString() ?? 'Verification code sent',
        success: true,
      );
    } catch (e) {
      debugPrint('🔴 OTP ERROR: $e');

      if (!mounted) return;

      String message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      _showMessage(message, success: false);
    } finally {
      if (mounted) {
        setState(() {
          _sendingOtp = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _seconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();

        if (mounted) {
          setState(() {
            _seconds = 0;
          });
        }

        return;
      }

      if (mounted) {
        setState(() {
          _seconds--;
        });
      }
    });
  }

 
  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (index == 5 && value.isNotEmpty) {
      _focusNodes[index].unfocus();
    }
  }

  String _getOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

 
  void _verifyOtp() {
    if (_verifying) return;

    final otp = _getOtp();

    if (otp.length != 6) {
      _showMessage(
        'Please enter the 6-digit verification code',
        success: false,
      );
      return;
    }

    final data = Map<String, dynamic>.from(widget.registerData);

    data['phone'] = _normalizePhone(widget.phone);

    data['otp_code'] = otp;

    debugPrint('================================');
    debugPrint('REGISTER DATA');
    debugPrint(data.toString());
    debugPrint('================================');

    widget.registerBloc.add(RegisterSubmitted(registerData: data));
  }


  String _normalizePhone(String phone) {
    phone = phone.trim().replaceAll(' ', '').replaceAll('-', '');

    if (phone.startsWith('+963')) {
      return '0${phone.substring(4)}';
    }

    if (phone.startsWith('00963')) {
      return '0${phone.substring(5)}';
    }

    if (phone.startsWith('963')) {
      return '0${phone.substring(3)}';
    }

    return phone;
  }

 
  void _showMessage(String message, {required bool success}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: widget.registerBloc,
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterLoading) {
            setState(() {
              _verifying = true;
            });
          }

          if (state is RegisterSuccess) {
            setState(() {
              _verifying = false;
            });

            _showMessage('Account created successfully 🎉', success: true);

            Future.delayed(const Duration(milliseconds: 700), () {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<HomeBloc>(),
                      child: const HomeScreen(),
                    ),
                  ),
                  (route) => false,
                );
              }
            });
          }

          if (state is RegisterFailure) {
            setState(() {
              _verifying = false;
            });

            _showMessage(state.message, success: false);
          }
        },
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.accentLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Verify phone'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 70,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Verify your phone number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'We sent a 6-digit verification code to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textDark.withOpacity(.6)
                          : AppColors.textLight.withOpacity(.6),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.phone,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        height: 55,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          onChanged: (value) {
                            _onChanged(index, value);
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),

                  CustomButton(
                    isLoading: _verifying,
                    onTap: _verifying ? () {} : _verifyOtp,
                    text: 'Verify & Create Account',
                  ),

                  const SizedBox(height: 24),

                  if (_seconds > 0)
                    Text(
                      'Resend code in $_seconds s',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDark.withOpacity(.5)
                            : AppColors.textLight.withOpacity(.5),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _sendingOtp
                          ? null
                          : () {
                              _startTimer();
                              _sendOtp();
                            },
                      child: const Text('Resend code'),
                    ),

                  if (_sendingOtp)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('Sending verification code...'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

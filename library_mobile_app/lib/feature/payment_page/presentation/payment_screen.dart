import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constantPage.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/Bill/presentation/BillDetailsScreen.dart';
import 'package:library_mobile_app/feature/payment_page/data/payment_mode.dart';
import 'package:library_mobile_app/feature/payment_page/data/repository.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CheckoutItemModel> cartItems;

  const CheckoutScreen({super.key, this.cartItems = const []});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(paymentRepository: PaymentRepository()),
      child: CheckoutViewContent(cartItems: cartItems),
    );
  }
}

class CheckoutViewContent extends StatefulWidget {
  final List<CheckoutItemModel> cartItems;

  const CheckoutViewContent({super.key, required this.cartItems});

  @override
  _CheckoutViewContentState createState() => _CheckoutViewContentState();
}

class _CheckoutViewContentState extends State<CheckoutViewContent> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showTopNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final accent = AppColors.primary;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          localizations.checkoutAndPayment,
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            _showSuccessDialog(
              context,
              state,
              isDark,
              localizations,
              accent,
              primaryText,
              secondaryText,
              cardColor,
            );
          } else if (state is PaymentFailure) {
            _showTopNotification(context, state.error);
          }
        },
        builder: (context, state) {
          final paymentBloc = context.read<PaymentBloc>();
          final String currentPayment = paymentBloc.selectedPayment;
          final bool currentDelivery = paymentBloc.wantsDelivery;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSection(
                  localizations.personalInformation,
                  [
                    _buildTextField(
                      localizations.phoneNumber,
                      _phoneController,
                      isPhone: true,
                      isDark: isDark,
                      accent: accent,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      localizations.detailedAddress,
                      _addressController,
                      isDark: isDark,
                      accent: accent,
                      secondaryText: secondaryText,
                    ),
                  ],
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accent: accent,
                  primaryText: primaryText,
                ),

                const SizedBox(height: 16),

                _buildSection(
                  localizations.deliveryService,
                  [
                    RadioListTile<bool>(
                      title: Text(
                        localizations.yesWantsDelivery,
                        style: TextStyle(color: primaryText),
                      ),
                      secondary: Icon(Icons.delivery_dining, color: accent),
                      activeColor: accent,
                      value: true,
                      groupValue: currentDelivery,
                      onChanged: (v) {
                        if (v != null) {
                          context.read<PaymentBloc>().add(
                            UpdateDeliveryEvent(v),
                          );
                        }
                      },
                    ),
                    RadioListTile<bool>(
                      title: Text(
                        localizations.noStorePickup,
                        style: TextStyle(color: primaryText),
                      ),
                      secondary: Icon(Icons.store, color: accent),
                      activeColor: accent,
                      value: false,
                      groupValue: currentDelivery,
                      onChanged: (v) {
                        if (v != null) {
                          context.read<PaymentBloc>().add(
                            UpdateDeliveryEvent(v),
                          );
                        }
                      },
                    ),
                  ],
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accent: accent,
                  primaryText: primaryText,
                ),

                const SizedBox(height: 16),

                _buildSection(
                  localizations.paymentMethod,
                  [
                    RadioListTile<String>(
                      title: Text(
                        'Points',
                        style: TextStyle(color: primaryText),
                      ),
                      secondary: Icon(Icons.stars_rounded, color: accent),
                      activeColor: accent,
                      value: 'points',
                      groupValue: currentPayment,
                      onChanged: (v) {
                        if (v != null) {
                          context.read<PaymentBloc>().add(
                            UpdatePaymentMethodEvent(v),
                          );
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(
                        localizations.cashOnDelivery,
                        style: TextStyle(color: primaryText),
                      ),
                      secondary: Icon(Icons.money, color: accent),
                      activeColor: accent,
                      value: 'cash',
                      groupValue: currentPayment,
                      onChanged: (v) {
                        if (v != null) {
                          context.read<PaymentBloc>().add(
                            UpdatePaymentMethodEvent(v),
                          );
                        }
                      },
                    ),
                  ],
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accent: accent,
                  primaryText: primaryText,
                ),

                const SizedBox(height: 30),

                state is PaymentLoading
                    ? CircularProgressIndicator(color: accent)
                    : _buildConfirmButton(
                        context,
                        isDark,
                        localizations,
                        accent: accent,
                        onPressed: () {
                          if (_phoneController.text.trim().isEmpty ||
                              _addressController.text.trim().isEmpty) {
                            _showTopNotification(
                              context,
                              'Please fill in your phone number and address before confirming',
                            );
                            return;
                          }

                          context.read<PaymentBloc>().add(
                            ConfirmPaymentEvent(
                              phoneNumber: _phoneController.text.trim(),
                              deliveryAddress: _addressController.text.trim(),
                              items: widget.cartItems,
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    bool isDark,
    AppLocalizations localizations, {
    required Color accent,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        elevation: 6,
        shadowColor: accent.withOpacity(0.4),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent, accent.withOpacity(0.75)],
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Text(
                  localizations.confirmOrderAndPay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    PaymentSuccess state,
    bool isDark,
    AppLocalizations localizations,
    Color accent,
    Color primaryText,
    Color secondaryText,
    Color cardColor,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: Text(
          localizations.orderReceived,
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${localizations.orderId}: ${state.orderId}",
              style: TextStyle(color: primaryText, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "${localizations.date}: ${state.date}",
              style: TextStyle(color: secondaryText),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);

              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(Routes.homePage, (route) => false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BillDetailsScreen(
                    billId: int.tryParse(state.orderId.toString()) ?? 0,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long, size: 18),
            label: const Text("View Bill"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(Routes.homePage, (route) => false);
            },
            child: Text(
              localizations.backToHome,
              style: TextStyle(color: accent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children, {
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color accent,
    required Color primaryText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: accent,
            ),
          ),
          Divider(color: borderColor),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPhone = false,
    required bool isDark,
    required Color accent,
    required Color secondaryText,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryText),
        prefixIcon: Icon(isPhone ? Icons.phone : Icons.edit, color: accent),
        filled: true,
        fillColor: isDark ? AppColors.inputDark : AppColors.inputLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}

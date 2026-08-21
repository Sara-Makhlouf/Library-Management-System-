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
  State<CheckoutViewContent> createState() => _CheckoutViewContentState();
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final localizations = AppLocalizations.of(context)!;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white60 : AppColors.textGrey;

    final accent = AppColors.primary;

    final borderColor = isDark
        ? Colors.white.withOpacity(0.055)
        : Colors.black.withOpacity(0.045);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        centerTitle: false,
        titleSpacing: 20,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.checkoutAndPayment,
              style: TextStyle(
                color: primaryText,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              'Complete your order securely',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: accent, size: 21),
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================
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

          final currentPayment = paymentBloc.selectedPayment;

          final currentDelivery = paymentBloc.wantsDelivery;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // ORDER SUMMARY
                // ==================================================
                _buildOrderSummary(
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accent: accent,
                  itemCount: widget.cartItems.length,
                ),

                const SizedBox(height: 18),

                // ==================================================
                // PERSONAL INFORMATION
                // ==================================================
                _buildSection(
                  title: localizations.personalInformation,
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildTextField(
                      localizations.phoneNumber,
                      _phoneController,
                      isPhone: true,
                      isDark: isDark,
                      accent: accent,
                      secondaryText: secondaryText,
                    ),

                    const SizedBox(height: 12),

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
                  secondaryText: secondaryText,
                ),

                const SizedBox(height: 16),

                // ==================================================
                // DELIVERY
                // ==================================================
                _buildSection(
                  title: localizations.deliveryService,
                  icon: Icons.local_shipping_outlined,
                  children: [
                    _buildRadioOption<bool>(
                      title: localizations.yesWantsDelivery,
                      subtitle: 'Receive your order at home',
                      icon: Icons.delivery_dining_rounded,
                      value: true,
                      groupValue: currentDelivery,
                      accent: accent,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<PaymentBloc>().add(
                            UpdateDeliveryEvent(value),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildRadioOption<bool>(
                      title: localizations.noStorePickup,
                      subtitle: 'Pick up your order from the store',
                      icon: Icons.storefront_outlined,
                      value: false,
                      groupValue: currentDelivery,
                      accent: accent,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<PaymentBloc>().add(
                            UpdateDeliveryEvent(value),
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
                  secondaryText: secondaryText,
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PAYMENT METHOD
                // ==================================================
                _buildSection(
                  title: localizations.paymentMethod,
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    _buildRadioOption<String>(
                      title: 'Points',
                      subtitle: 'Pay using your available points',
                      icon: Icons.stars_rounded,
                      value: 'points',
                      groupValue: currentPayment,
                      accent: accent,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<PaymentBloc>().add(
                            UpdatePaymentMethodEvent(value),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildRadioOption<String>(
                      title: localizations.cashOnDelivery,
                      subtitle: 'Pay when your order arrives',
                      icon: Icons.payments_outlined,
                      value: 'cash',
                      groupValue: currentPayment,
                      accent: accent,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<PaymentBloc>().add(
                            UpdatePaymentMethodEvent(value),
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
                  secondaryText: secondaryText,
                ),

                const SizedBox(height: 24),

                // ==================================================
                // CONFIRM BUTTON
                // ==================================================
                state is PaymentLoading
                    ? Center(
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: accent,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      )
                    : _buildConfirmButton(
                        context,
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
              ],
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // ORDER SUMMARY
  // ================================================================

  Widget _buildOrderSummary({
    required Color primaryText,
    required Color secondaryText,
    required Color cardColor,
    required Color borderColor,
    required Color accent,
    required int itemCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.shopping_cart_outlined, color: accent, size: 23),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Order',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'} ready for checkout',
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios_rounded, size: 15, color: secondaryText),
        ],
      ),
    );
  }

  // ================================================================
  // SECTION
  // ================================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),

              const SizedBox(width: 11),

              Text(
                title,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(height: 1, color: borderColor),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  // ================================================================
  // RADIO OPTION
  // ================================================================

  Widget _buildRadioOption<T>({
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required T groupValue,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
    required ValueChanged<T?> onChanged,
  }) {
    final selected = value == groupValue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? accent.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: selected ? accent.withOpacity(0.25) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: selected
                  ? accent.withOpacity(0.12)
                  : secondaryText.withOpacity(0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: selected ? accent : secondaryText,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: secondaryText, fontSize: 11.5),
                ),
              ],
            ),
          ),

          Radio<T>(
            value: value,
            groupValue: groupValue,
            activeColor: accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TEXT FIELD
  // ================================================================

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
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: isPhone ? 1 : 2,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryText, fontSize: 13),
        prefixIcon: Icon(
          isPhone ? Icons.phone_outlined : Icons.location_on_outlined,
          color: accent,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? AppColors.inputDark : AppColors.inputLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.055)
                : Colors.black.withOpacity(0.045),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }

  // ================================================================
  // CONFIRM BUTTON
  // ================================================================

  Widget _buildConfirmButton(
    BuildContext context,
    AppLocalizations localizations, {
    required Color accent,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [accent, accent.withOpacity(0.75)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 19,
                ),

                const SizedBox(width: 9),

                Text(
                  localizations.confirmOrderAndPay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SUCCESS DIALOG
  // ================================================================

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
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          contentPadding: const EdgeInsets.fromLTRB(24, 26, 24, 18),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 42,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                localizations.orderReceived,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.035),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildDialogInfoRow(
                      localizations.orderId,
                      state.orderId.toString(),
                      primaryText,
                      secondaryText,
                    ),

                    const SizedBox(height: 10),

                    _buildDialogInfoRow(
                      localizations.date,
                      state.date,
                      primaryText,
                      secondaryText,
                    ),
                  ],
                ),
              ),
            ],
          ),

          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),

          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);

                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.homePage, (route) => false);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BillDetailsScreen(
                        billId: int.tryParse(state.orderId.toString()) ?? 0,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: const Text(
                  'View Bill',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 4),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.homePage, (route) => false);
                },
                child: Text(
                  localizations.backToHome,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogInfoRow(
    String label,
    String value,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: secondaryText, fontSize: 12)),
        const SizedBox(width: 15),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

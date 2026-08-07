import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/payment_page/data/repository.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

// 1. The top-level screen wraps everything in a BlocProvider once
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(paymentRepository: PaymentRepository()),
      child: const CheckoutViewContent(),
    );
  }
}

// 2. The actual screen content
class CheckoutViewContent extends StatefulWidget {
  const CheckoutViewContent({super.key});

  @override
  _CheckoutViewContentState createState() => _CheckoutViewContentState();
}

class _CheckoutViewContentState extends State<CheckoutViewContent> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Shows a notification from the top of the screen
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    int buyingCount = 0;
    int borrowingCount = 0;
    double totalPrice = 0.0;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFEFE3D3),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        title: Text(
          localizations.checkoutAndPayment,
          style: TextStyle(
            color: isDark
                ? AppColors.primary
                : const Color.fromARGB(255, 96, 82, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkCard
            : const Color.fromARGB(255, 189, 170, 127),
        centerTitle: true,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            _showSuccessDialog(context, state, isDark, localizations);
          } else if (state is PaymentFailure) {
            _showTopNotification(context, state.error);
          }
        },
        builder: (context, state) {
          // Read the current values directly from the stable state in the Bloc
          String currentPayment = 'cash';
          bool currentDelivery = true;

          if (state is PaymentInitial) {
            currentPayment = state.selectedPayment;
            currentDelivery = state.wantsDelivery;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSection(localizations.invoiceSummary, [
                  _buildSummaryRow(
                    localizations.buyingBooks,
                    "$buyingCount Items",
                    isDark,
                  ),
                  _buildSummaryRow(
                    localizations.borrowingBooks,
                    "$borrowingCount Items",
                    isDark,
                  ),
                  Divider(
                    color: isDark
                        ? AppColors.textGrey.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.5),
                  ),
                  _buildSummaryRow(
                    localizations.totalPrice,
                    "${totalPrice.toStringAsFixed(0)} ل.س",
                    isDark,
                    isTotal: true,
                  ),
                ], isDark: isDark),
                const SizedBox(height: 16),
                _buildSection(localizations.personalInformation, [
                  _buildTextField(
                    localizations.fullName,
                    _nameController,
                    isDark: isDark,
                  ),
                  _buildTextField(
                    localizations.phoneNumber,
                    _phoneController,
                    isPhone: true,
                    isDark: isDark,
                  ),
                  _buildTextField(
                    localizations.detailedAddress,
                    _addressController,
                    isDark: isDark,
                  ),
                ], isDark: isDark),
                const SizedBox(height: 16),
                _buildSection(localizations.deliveryService, [
                  RadioListTile<bool>(
                    title: Text(
                      localizations.yesWantsDelivery,
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : Colors.black87,
                      ),
                    ),
                    secondary: Icon(
                      Icons.delivery_dining,
                      color: isDark
                          ? AppColors.primary
                          : const Color.fromARGB(255, 96, 82, 50),
                    ),
                    activeColor: isDark
                        ? AppColors.primary
                        : const Color.fromARGB(255, 96, 82, 50),
                    value: true,
                    groupValue: currentDelivery,
                    onChanged: (v) {
                      if (v != null) {
                        context.read<PaymentBloc>().add(UpdateDeliveryEvent(v));
                      }
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text(
                      localizations.noStorePickup,
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : Colors.black87,
                      ),
                    ),
                    secondary: Icon(
                      Icons.store,
                      color: isDark
                          ? AppColors.primary
                          : const Color.fromARGB(255, 96, 82, 50),
                    ),
                    activeColor: isDark
                        ? AppColors.primary
                        : const Color.fromARGB(255, 96, 82, 50),
                    value: false,
                    groupValue: currentDelivery,
                    onChanged: (v) {
                      if (v != null) {
                        context.read<PaymentBloc>().add(UpdateDeliveryEvent(v));
                      }
                    },
                  ),
                ], isDark: isDark),
                const SizedBox(height: 16),
                _buildSection(localizations.paymentMethod, [
                  RadioListTile<String>(
                    title: Text(
                      localizations.creditCard,
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : Colors.black87,
                      ),
                    ),
                    secondary: Icon(
                      Icons.credit_card,
                      color: isDark
                          ? AppColors.primary
                          : const Color.fromARGB(255, 96, 82, 50),
                    ),
                    activeColor: isDark
                        ? AppColors.primary
                        : const Color.fromARGB(255, 96, 82, 50),
                    value: 'online',
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
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : Colors.black87,
                      ),
                    ),
                    secondary: Icon(
                      Icons.money,
                      color: isDark
                          ? AppColors.primary
                          : const Color.fromARGB(255, 96, 82, 50),
                    ),
                    activeColor: isDark
                        ? AppColors.primary
                        : const Color.fromARGB(255, 96, 82, 50),
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
                ], isDark: isDark),
                const SizedBox(height: 30),
                state is PaymentLoading
                    ? CircularProgressIndicator(
                        color: isDark
                            ? AppColors.primary
                            : const Color.fromARGB(255, 96, 82, 50),
                      )
                    : _buildConfirmButton(
                        context,
                        isDark,
                        localizations,
                        onPressed: () {
                          // 1. Check whether the text fields are empty
                          if (_nameController.text.trim().isEmpty ||
                              _phoneController.text.trim().isEmpty ||
                              _addressController.text.trim().isEmpty) {
                            _showTopNotification(
                              context,
                              'Please fill in all your personal information before confirming',
                            );
                            return; // Stop here, don't submit the order
                          }

                          // 2. Radio selections already carry default values in the state, so they're always filled

                          // Everything looks good, dispatch the event to the Bloc
                          context.read<PaymentBloc>().add(
                            ConfirmPaymentEvent(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              address: _addressController.text,
                            ),
                          );
                        },
                      ),
                // Extra breathing room so the button doesn't sit flush
                // against the very bottom of the scroll view.
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
    required VoidCallback onPressed,
  }) {
    final gradientColors = isDark
        ? [AppColors.primary, AppColors.primary.withOpacity(0.75)]
        : [
            const Color.fromARGB(255, 96, 82, 50),
            const Color.fromARGB(255, 148, 128, 84),
          ];

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        elevation: 6,
        shadowColor: (isDark ? AppColors.primary : const Color(0xFF605232))
            .withOpacity(0.4),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
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

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textDark : Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? (isDark
                        ? AppColors.primary
                        : const Color.fromARGB(255, 96, 82, 50))
                  : (isDark ? AppColors.textDark : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    PaymentSuccess state,
    bool isDark,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : const Color(0xFFEFE3D3),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: Text(
          localizations.orderReceived,
          style: TextStyle(color: isDark ? AppColors.textDark : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${localizations.orderId}: ${state.orderId}",
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black87,
              ),
            ),
            Text(
              "${localizations.date}: ${state.date}",
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(localizations.backToHome),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children, {
    required bool isDark,
  }) {
    return Card(
      color: isDark ? AppColors.darkCard : AppColors.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark
                    ? AppColors.primary
                    : const Color.fromARGB(255, 96, 82, 50),
              ),
            ),
            Divider(
              color: isDark
                  ? AppColors.textGrey.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.4),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPhone = false,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? AppColors.textDark : Colors.black87),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? AppColors.inputDark : const Color(0xFFEFE3D3),
          labelText: label,
          prefixIcon: Icon(
            isPhone ? Icons.phone : Icons.edit,
            color: isDark ? AppColors.primary : Colors.black54,
          ),
        ),
      ),
    );
  }
}

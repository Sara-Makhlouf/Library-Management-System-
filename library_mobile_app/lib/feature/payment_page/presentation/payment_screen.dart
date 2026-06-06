import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // استيراد حزمة الأنميشن
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';

import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedPayment = 'card';
  bool _wantsDelivery = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cartState = context.read<CartBloc>().state;
    int buyingCount = 0;
    int borrowingCount = 0;
    double totalPrice = 0.0;

    if (cartState is CartLoaded) {
      buyingCount = cartState.cartItems
          .where((item) => item.isBorrow != true)
          .length;
      borrowingCount = cartState.cartItems
          .where((item) => item.isBorrow == true)
          .length;
      totalPrice = cartState.totalAmount;
    }

    return BlocProvider(
      create: (context) => CheckoutBloc(),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFEFE3D3),
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          title: Text(
            "Checkout & Payment",
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
          iconTheme: IconThemeData(
            color: isDark
                ? AppColors.primary
                : const Color.fromARGB(255, 96, 82, 50),
          ),
        ),
        body: BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              _showSuccessDialog(
                context,
                state,
                buyingCount,
                borrowingCount,
                isDark,
              );
            } else if (state is CheckoutFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- 1. Order Summary / Invoice ---
                  _buildSection(
                    "Invoice Summary",
                    [
                      _buildSummaryRow(
                        "Buying Books:",
                        "$buyingCount Items",
                        isDark,
                      ),
                      _buildSummaryRow(
                        "Borrowing Books:",
                        "$borrowingCount Items",
                        isDark,
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.textGrey.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.5),
                      ),
                      _buildSummaryRow(
                        "Total Price:",
                        "${totalPrice.toStringAsFixed(0)} ل.س",
                        isDark,
                        isTotal: true,
                      ),
                    ],
                    index: 0,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  // --- 2. Personal Information ---
                  _buildSection(
                    "Personal Information",
                    [
                      _buildTextField(
                        "Full Name",
                        _nameController,
                        isDark: isDark,
                      ),
                      _buildTextField(
                        "Phone Number",
                        _phoneController,
                        isPhone: true,
                        isDark: isDark,
                      ),
                      _buildTextField(
                        "Detailed Address",
                        _addressController,
                        isDark: isDark,
                      ),
                    ],
                    index: 1,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  // --- 3. Delivery Service ---
                  _buildSection(
                    "Delivery Service",
                    [
                      RadioListTile<bool>(
                        title: Text(
                          "Yes, I want delivery",
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
                        groupValue: _wantsDelivery,
                        onChanged: (v) => setState(() => _wantsDelivery = v!),
                      ),
                      RadioListTile<bool>(
                        title: Text(
                          "No, I will pick it up",
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
                        groupValue: _wantsDelivery,
                        onChanged: (v) => setState(() => _wantsDelivery = v!),
                      ),
                    ],
                    index: 2,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  // --- 4. Payment Method ---
                  _buildSection(
                    "Payment Method",
                    [
                      RadioListTile(
                        title: Text(
                          "Credit Card",
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
                        value: 'card',
                        groupValue: _selectedPayment,
                        onChanged: (v) =>
                            setState(() => _selectedPayment = v.toString()),
                      ),
                      RadioListTile(
                        title: Text(
                          "Cash on Delivery",
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
                        groupValue: _selectedPayment,
                        onChanged: (v) =>
                            setState(() => _selectedPayment = v.toString()),
                      ),
                    ],
                    index: 3,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  // --- 5. Borrowing Terms Note ---
                  _buildSection(
                    "Borrowing Terms",
                    [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 28,
                        ),
                        title: Text(
                          "Important Note for Borrowed Books",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? AppColors.textDark : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "The maximum borrowing period is 7 days only from the date of receiving the order. Please ensure timely returns.",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textGrey : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                    index: 4,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 30),

                  // --- Submit Button ---
                  state is CheckoutLoading
                      ? CircularProgressIndicator(
                          color: isDark
                              ? AppColors.primary
                              : const Color.fromARGB(255, 96, 82, 50),
                        )
                      : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),

                                backgroundColor: isDark
                                    ? AppColors.inputDark
                                    : const Color.fromARGB(255, 189, 170, 127),
                              ),
                              onPressed: () {
                                context.read<CheckoutBloc>().add(
                                  ConfirmPaymentEvent(
                                    name: _nameController.text,
                                    phone: _phoneController.text,
                                    address: _addressController.text,
                                    paymentMethod: _selectedPayment,
                                    wantsDelivery: _wantsDelivery,
                                  ),
                                );
                              },
                              child: Text(
                                "Confirm Order Now",
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.primary
                                      : const Color.fromARGB(255, 96, 82, 50),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            ),
                ],
              ),
            );
          },
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
    CheckoutSuccess state,
    int buyingCount,
    int borrowingCount,
    bool isDark,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : const Color(0xFFEFE3D3),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: Text(
          "Order Received!",
          style: TextStyle(color: isDark ? AppColors.textDark : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${state.orderId}",
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black87,
              ),
            ),
            Text(
              "Date: ${state.date}",
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Buying Items: $buyingCount",
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black87,
              ),
            ),
            Text(
              "Borrowing Items: $borrowingCount",
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black87,
              ),
            ),
            Text(
              "Delivery: ${_wantsDelivery ? 'Requested' : 'Store Pickup'}",
              style: TextStyle(
                color: isDark ? AppColors.textDark : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.inputDark
                  : const Color.fromARGB(255, 189, 170, 127),
              foregroundColor: isDark
                  ? AppColors.primary
                  : const Color.fromARGB(255, 96, 82, 50),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back to Home"),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children, {
    int index = 0,
    required bool isDark,
  }) {
    return Card(
          color: isDark ? AppColors.darkCard : AppColors.accent,
          surfaceTintColor: isDark ? AppColors.darkCard : AppColors.accent,
          elevation: isDark ? 2 : 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isDark
                ? BorderSide(color: AppColors.textGrey.withOpacity(0.1))
                : BorderSide.none,
          ),
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
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
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
        cursorColor: isDark
            ? AppColors.primary
            : const Color.fromARGB(255, 234, 226, 218),
        controller: controller,
        style: TextStyle(color: isDark ? AppColors.textDark : Colors.black87),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          // ─── التعديل: تلوين حقول الإدخال لتتناسب مع الدارك مود ───
          fillColor: isDark ? AppColors.inputDark : const Color(0xFFEFE3D3),
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? AppColors.textGrey : Colors.black54,
          ),
          prefixIcon: Icon(
            isPhone ? Icons.phone : Icons.edit,
            color: isDark ? AppColors.primary : Colors.black54,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: isDark ? AppColors.primary : Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: isDark
                  ? AppColors.textGrey.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

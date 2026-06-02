import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';

import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../data/payment_mode.dart';

class CheckoutScreen extends StatefulWidget {
  final PaymentMode mode;
  const CheckoutScreen({super.key, required this.mode});

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
    return BlocProvider(
      create: (context) => CheckoutBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                25,
              ), // يمكنك زيادة الرقم لزيادة الانحناء (شكل بيضوي أكثر)
            ),
          ),

          title: Text(
            widget.mode == PaymentMode.buy
                ? "Confirm Purchase"
                : "Borrow Request",
            style: const TextStyle(color: Color.fromARGB(255, 96, 82, 50)),
          ),
          backgroundColor: const Color.fromARGB(255, 189, 170, 127),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 96, 82, 50),
          ),
        ),
        body: BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              _showSuccessDialog(context, state);
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
                  // --- Order Summary / Invoice (Only for Purchase) ---
                  if (widget.mode == PaymentMode.buy)
                    _buildSection("Order Summary", [
                      _buildSummaryRow("Total Books:", "3 Items"), // Mock Data
                      _buildSummaryRow("Total Price:", "\$120.00"), // Mock Data
                    ]),

                  if (widget.mode == PaymentMode.buy)
                    const SizedBox(height: 16),

                  // --- Personal Information ---
                  _buildSection("Personal Information", [
                    _buildTextField("Full Name", _nameController),
                    _buildTextField(
                      "Phone Number",
                      _phoneController,
                      isPhone: true,
                    ),
                    _buildTextField("Detailed Address", _addressController),
                  ]),

                  const SizedBox(height: 16),

                  // --- Delivery Service ---
                  _buildSection("Delivery Service", [
                    RadioListTile<bool>(
                      title: const Text("Yes, I want delivery"),
                      secondary: const Icon(Icons.delivery_dining),
                      value: true,
                      groupValue: _wantsDelivery,
                      onChanged: (v) => setState(() => _wantsDelivery = v!),
                    ),
                    RadioListTile<bool>(
                      title: const Text("No, I will pick it up"),
                      secondary: const Icon(Icons.store),
                      value: false,
                      groupValue: _wantsDelivery,
                      onChanged: (v) => setState(() => _wantsDelivery = v!),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // --- Payment Method (For Purchase) or Terms (For Borrowing) ---
                  if (widget.mode == PaymentMode.buy)
                    _buildSection("Payment Method", [
                      RadioListTile(
                        title: const Text("Credit Card"),
                        secondary: const Icon(Icons.credit_card),
                        value: 'card',
                        groupValue: _selectedPayment,
                        onChanged: (v) =>
                            setState(() => _selectedPayment = v.toString()),
                      ),
                      RadioListTile(
                        title: const Text("Cash on Delivery"),
                        secondary: const Icon(Icons.money),
                        value: 'cash',
                        groupValue: _selectedPayment,
                        onChanged: (v) =>
                            setState(() => _selectedPayment = v.toString()),
                      ),
                    ])
                  else
                    _buildSection("Borrowing Terms", [
                      const ListTile(
                        leading: Icon(
                          Icons.calendar_month,
                          color: Colors.orange,
                        ),
                        title: Text("Borrowing period: 7 days"),
                        subtitle: Text("Expected return date: May 22, 2026"),
                      ),
                    ]),

                  const SizedBox(height: 30),

                  // --- Submit Button ---
                  state is CheckoutLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            backgroundColor: const Color.fromARGB(
                              255,
                              189,
                              170,
                              127,
                            ),
                          ),
                          onPressed: () {
                            context.read<CheckoutBloc>().add(
                              ConfirmPaymentEvent(
                                name: _nameController.text,
                                phone: _phoneController.text,
                                address: _addressController.text,
                                isPurchase: widget.mode == PaymentMode.buy,
                                paymentMethod: widget.mode == PaymentMode.buy
                                    ? _selectedPayment
                                    : null,
                              ),
                            );
                          },
                          child: const Text(
                            "Confirm Order Now",
                            style: TextStyle(
                              color: Color.fromARGB(255, 96, 82, 50),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper for Order Summary rows
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, CheckoutSuccess state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text("Order Received!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Order ID: ${state.orderId}"),
            Text("Date: ${state.date}"),
            const SizedBox(height: 10),
            Text(
              "Type: ${widget.mode == PaymentMode.buy ? 'Purchase' : 'Borrowing'}",
            ),
            Text("Delivery: ${_wantsDelivery ? 'Requested' : 'Store Pickup'}"),
          ],
        ),
        actions: [
          ElevatedButton(
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

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: AppColors.accent,

      surfaceTintColor: AppColors.accent,
      elevation: 8,
      //  shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color.fromARGB(255, 96, 82, 50),
              ),
            ),
            const Divider(),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        cursorColor: Color.fromARGB(255, 234, 226, 218),
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(255, 234, 226, 218),
          labelText: label,
          prefixIcon: Icon(isPhone ? Icons.phone : Icons.edit),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
    );
  }
}

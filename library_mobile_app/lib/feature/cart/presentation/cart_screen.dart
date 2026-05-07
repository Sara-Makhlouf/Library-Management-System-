import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/presentation/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<CartBloc>().add(LoadCartEvent());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(" Shopping Cart"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 189, 170, 127),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoaded) {
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 80),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) =>
                        CartItemCard(item: state.cartItems[index]),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 189, 170, 127),
            foregroundColor: Color.fromARGB(255, 96, 82, 50),
          ),
          onPressed: () => _showOrderSummary(context),
          child: Text("Order Information"),
        ),
      ),
    );
  }

  void _showOrderSummary(BuildContext context) {
    final cartBloc = BlocProvider.of<CartBloc>(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: cartBloc,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 189, 170, 127),
              image: DecorationImage(
                image: AssetImage("lib/assets/images/logo.png.png"),
                scale: 1.0,
                //      fit: BoxFit.cover,
                opacity: 0.2,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 96, 82, 50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Order summary",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 96, 82, 50),
                    ),
                  ),
                  Divider(thickness: 1.5, color: Color(0xFFD8C8A8)),
                  SizedBox(height: 10),
                  Expanded(
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        if (state is CartLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSummaryRow(
                                "Number Books",
                                "${state.cartItems.length}",
                              ),
                              SizedBox(height: 15),
                              _buildSummaryRow(
                                "Total price",
                                "${state.totalAmount} ل.س",
                                isPrice: true,
                              ),
                            ],
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 96, 82, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/checkout'),
                      child: Text(
                        "Confirm the order",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.black)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPrice ? Colors.black : Colors.black,
          ),
        ),
      ],
    );
  }
}

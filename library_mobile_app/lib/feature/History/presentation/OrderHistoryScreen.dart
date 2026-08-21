import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_bloc.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is HistoryError) return Center(child: Text(state.message));
          if (state is HistoryLoaded) {
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Order #${order.id}"),
                    subtitle: Text("Date: ${order.date}"),
                    trailing: Chip(
                      label: Text(order.status),
                      backgroundColor: order.status == 'completed'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("No Orders Found"));
        },
      ),
    );
  }
}

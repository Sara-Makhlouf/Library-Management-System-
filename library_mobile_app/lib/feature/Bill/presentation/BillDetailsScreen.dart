import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsBloc.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsEvent.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsState.dart';
import 'package:library_mobile_app/feature/Bill/data/BillsRepository.dart';

class BillDetailsScreen extends StatelessWidget {
  final int billId;

  const BillDetailsScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return BlocProvider(
      create: (context) =>
          BillsBloc(billsRepository: BillsRepository())
            ..add(FetchBillDetailsEvent(billId)),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            'Invoice #$billId',
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
        body: BlocBuilder<BillsBloc, BillsState>(
          builder: (context, state) {
            if (state is BillsLoading) {
              return Center(child: CircularProgressIndicator(color: accent));
            } else if (state is BillsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.error,
                      style: TextStyle(color: secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (state is BillDetailsLoaded) {
              final bill = state.bill;
              final isPaid = bill.status.toLowerCase() == 'paid';
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Invoice Info Card ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.receipt_outlined,
                                  color: accent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${bill.id}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      bill.createdAt,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(height: 1, color: borderColor),
                          const SizedBox(height: 16),
                          _infoRow(
                            Icons.info_outline,
                            'Status',
                            bill.status.toUpperCase(),
                            primaryText,
                            secondaryText,
                            accent,
                            valueColor: isPaid ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(height: 10),
                          _infoRow(
                            Icons.payment_outlined,
                            'Payment Method',
                            bill.paymentMethod.toUpperCase(),
                            primaryText,
                            secondaryText,
                            accent,
                          ),
                          const SizedBox(height: 10),
                          _infoRow(
                            Icons.local_shipping_outlined,
                            'Delivery',
                            bill.isDelivery ? 'Home Delivery' : 'Store Pickup',
                            primaryText,
                            secondaryText,
                            accent,
                          ),
                          if (bill.deliveryAddress != null &&
                              bill.deliveryAddress!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _infoRow(
                              Icons.location_on_outlined,
                              'Address',
                              bill.deliveryAddress!,
                              primaryText,
                              secondaryText,
                              accent,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // --- Ordered Items ---
                    const SizedBox(height: 24),
                    Text(
                      'Ordered Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bill.items.length,
                      itemBuilder: (context, index) {
                        final item = bill.items[index];
                        final bool isBorrow =
                            item.type.toLowerCase() == 'borrow';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.book_outlined,
                                  color: accent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.bookTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: primaryText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          'Qty: ${item.quantity}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: secondaryText,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isBorrow
                                                ? Colors.orange.withOpacity(
                                                    0.12,
                                                  )
                                                : const Color(
                                                    0xFF2563EB,
                                                  ).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isBorrow ? 'Borrow' : 'Buy',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isBorrow
                                                  ? Colors.orange
                                                  : const Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${item.price}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // --- Total Price ---
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          Text(
                            '\$${bill.totalPrice}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color primaryText,
    Color secondaryText,
    Color accent, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

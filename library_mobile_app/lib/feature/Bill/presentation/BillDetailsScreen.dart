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

        // ----------------------------------------------------------
        // APP BAR
        // ----------------------------------------------------------
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice #$billId',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Invoice details',
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
              child: Icon(Icons.receipt_long_rounded, color: accent, size: 21),
            ),
          ],
          iconTheme: IconThemeData(color: primaryText),
        ),
        body: BlocBuilder<BillsBloc, BillsState>(
          builder: (context, state) {
            // ------------------------------------------------------
            // LOADING
            // ------------------------------------------------------
            if (state is BillsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: accent,
                  strokeWidth: 2.5,
                ),
              );
            }

            // ------------------------------------------------------
            // ERROR
            // ------------------------------------------------------
            if (state is BillsError) {
              return _buildErrorState(
                context,
                state.error,
                secondaryText,
                accent,
              );
            }

            // ------------------------------------------------------
            // LOADED
            // ------------------------------------------------------
            if (state is BillDetailsLoaded) {
              final bill = state.bill;

              final isPaid = bill.status.toLowerCase() == 'paid';

              final statusColor = isPaid ? Colors.green : Colors.orange;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // INVOICE HEADER
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.055),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Invoice icon
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      accent.withOpacity(0.18),
                                      accent.withOpacity(0.07),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: accent,
                                  size: 28,
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
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 13,
                                          color: secondaryText,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            bill.createdAt,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: secondaryText,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Status badge
                              _buildStatusBadge(bill.status, statusColor),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Divider(height: 1, color: borderColor),

                          const SizedBox(height: 18),

                          // ==================================================
                          // INFORMATION
                          // ==================================================
                          _infoRow(
                            Icons.info_outline_rounded,
                            'Status',
                            bill.status.toUpperCase(),
                            primaryText,
                            secondaryText,
                            accent,
                            valueColor: statusColor,
                          ),

                          const SizedBox(height: 14),

                          _infoRow(
                            Icons.account_balance_wallet_outlined,
                            'Payment Method',
                            bill.paymentMethod.toUpperCase(),
                            primaryText,
                            secondaryText,
                            accent,
                          ),

                          const SizedBox(height: 14),

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
                            const SizedBox(height: 14),

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

                    const SizedBox(height: 28),

                    // ==================================================
                    // ORDERED ITEMS HEADER
                    // ==================================================
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Ordered Items',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${bill.items.length} items',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // ITEMS
                    // ==================================================
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bill.items.length,
                      itemBuilder: (context, index) {
                        final item = bill.items[index];

                        final isBorrow = item.type.toLowerCase() == 'borrow';

                        return _buildItemCard(
                          item,
                          isBorrow,
                          cardColor,
                          borderColor,
                          primaryText,
                          secondaryText,
                          accent,
                          isDark,
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // TOTAL
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withOpacity(0.14),
                            accent.withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withOpacity(0.25)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: accent,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Order total',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryText.withOpacity(0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${bill.totalPrice}',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Small footer
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 15,
                            color: secondaryText.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Thank you for your order',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  // ================================================================
  // ERROR STATE
  // ================================================================

  Widget _buildErrorState(
    BuildContext context,
    String error,
    Color secondaryText,
    Color accent,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.red.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: secondaryText,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              style: TextStyle(
                fontSize: 13,
                color: secondaryText.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // STATUS BADGE
  // ================================================================

  Widget _buildStatusBadge(String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.11),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ITEM CARD
  // ================================================================

  Widget _buildItemCard(
    dynamic item,
    bool isBorrow,
    Color cardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
    Color accent,
    bool isDark,
  ) {
    final itemTypeColor = isBorrow ? Colors.orange : const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Book icon
          Container(
            width: 50,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.14), accent.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.menu_book_rounded, color: accent, size: 25),
          ),

          const SizedBox(width: 13),

          // Book information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.bookTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered_rounded,
                      size: 14,
                      color: secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),

                    const SizedBox(width: 9),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: itemTypeColor.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBorrow ? 'Borrow' : 'Buy',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: itemTypeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Price',
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryText.withOpacity(0.65),
                ),
              ),
              const SizedBox(height: 3),
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
        ],
      ),
    );
  }

  // ================================================================
  // INFO ROW
  // ================================================================

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
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: accent),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

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

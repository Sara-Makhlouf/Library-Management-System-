import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsBloc.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsEvent.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsState.dart';
import 'package:library_mobile_app/feature/Bill/data/BillsRepository.dart';
import 'package:library_mobile_app/feature/Bill/presentation/BillDetailsScreen.dart';

class AllBillsScreen extends StatelessWidget {
  const AllBillsScreen({super.key});

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
            ..add(FetchAllBillsEvent()),
      child: Scaffold(
        backgroundColor: bgColor,

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
                'My Invoices',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Your invoice history',
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
        ),

        body: BlocBuilder<BillsBloc, BillsState>(
          builder: (context, state) {
            // =========================
            // LOADING
            // =========================
            if (state is BillsLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: CircularProgressIndicator(
                          color: accent,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your invoices...',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // =========================
            // ERROR
            // =========================
            if (state is BillsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
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
                          Icons.receipt_long_outlined,
                          size: 38,
                          color: Colors.red.withOpacity(0.65),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Unable to load invoices',
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        state.error,
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // =========================
            // LOADED
            // =========================
            if (state is AllBillsLoaded) {
              final bills = state.bills;

              // =========================
              // EMPTY
              // =========================
              if (bills.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 55,
                            color: accent.withOpacity(0.35),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          'No invoices yet',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Your completed orders and invoices\nwill appear here.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // =========================
              // BILLS LIST
              // =========================
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];

                  return _buildBillCard(
                    context: context,
                    bill: bill,
                    index: index,
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardColor: cardColor,
                    accent: accent,
                    borderColor: borderColor,
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ============================================================
  // BILL CARD
  // ============================================================

  Widget _buildBillCard({
    required BuildContext context,
    required dynamic bill,
    required int index,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required Color cardColor,
    required Color accent,
    required Color borderColor,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 70)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.045),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BillDetailsScreen(billId: bill.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // ==================================================
                  // TOP ROW
                  // ==================================================
                  Row(
                    children: [
                      // Invoice Icon
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent.withOpacity(0.16),
                              accent.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: accent,
                          size: 27,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Invoice Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice #${bill.id}',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                                    '${bill.createdAt}',
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.07),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: accent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // DIVIDER
                  // ==================================================
                  Divider(height: 1, thickness: 0.7, color: borderColor),

                  const SizedBox(height: 13),

                  // ==================================================
                  // BOTTOM INFO
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 18,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Total amount',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '\$${bill.totalPrice}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

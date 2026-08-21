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
          title: Text(
            'My Invoices',
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
            } else if (state is AllBillsLoaded) {
              final bills = state.bills;
              if (bills.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: accent.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No invoices yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your invoices will appear here',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryText.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BillDetailsScreen(billId: bill.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
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
                                      'Invoice #${bill.id}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Date: ${bill.createdAt}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '\$${bill.totalPrice}',
                                        style: TextStyle(
                                          color: accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
}

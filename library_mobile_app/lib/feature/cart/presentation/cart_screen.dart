import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/presentation/widgets/cart_item.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFEFE3D3),
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          title: Text(
            localizations.shoppingCart,
            style: TextStyle(
              color: isDark ? AppColors.textDark : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: isDark
              ? AppColors.darkCard
              : const Color.fromARGB(255, 189, 170, 127),
          bottom: TabBar(
            indicatorColor: isDark
                ? AppColors.primary
                : const Color.fromARGB(255, 96, 82, 50),
            labelColor: isDark
                ? AppColors.primary
                : const Color.fromARGB(255, 96, 82, 50),
            unselectedLabelColor: isDark ? AppColors.textGrey : Colors.white70,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: localizations.buyingTab),
              Tab(text: localizations.borrowingTab),
            ],
          ),
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoaded) {
              final buyingItems = state.cart.details
                  .where((item) => item.type != 'borrow')
                  .toList();

              final borrowingItems = state.cart.details
                  .where((item) => item.type == 'borrow')
                  .toList();

              // التحقق من أن السلة فارغة
              final bool isCartEmpty = state.cart.details.isEmpty;

              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCartList(
                          buyingItems,
                          isDark,
                          localizations,
                          'buying_list',
                        ),
                        _buildCartList(
                          borrowingItems,
                          isDark,
                          localizations,
                          'borrowing_list',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 90,
                      left: 20,
                      right: 20,
                      top: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.inputDark
                              : const Color.fromARGB(255, 189, 170, 127),
                          foregroundColor: isDark
                              ? AppColors.primary
                              : const Color.fromARGB(255, 96, 82, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: isDark
                                ? BorderSide(
                                    color: AppColors.primary.withOpacity(0.3),
                                  )
                                : BorderSide.none,
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // الشرط: إذا كانت السلة فارغة، أظهر تنبيه ولا تنتقل
                          if (isCartEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "عذراً، سلة المشتريات فارغة تماماً، لا يمكن إتمام الطلب.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // الانتقال لصفحة الدفع
                          Navigator.pushNamed(
                            context,
                            Routes.payment,
                            arguments: context.read<CartBloc>(),
                          );
                        },
                        child: Text(
                          localizations.confirmOrderAndPay,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: isDark
                    ? AppColors.primary
                    : const Color.fromARGB(255, 96, 82, 50),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartList(
    List<dynamic> items,
    bool isDark,
    AppLocalizations localizations,
    String listKey,
  ) {
    if (items.isEmpty) {
      return Center(
        key: ValueKey('${listKey}_empty'),
        child: Text(
          localizations.noItemsInSection,
          style: TextStyle(
            color: isDark ? AppColors.textGrey : Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.builder(
      key: ValueKey(listKey),
      padding: const EdgeInsets.only(bottom: 20, top: 15, left: 10, right: 10),
      itemCount: items.length,
      itemBuilder: (context, index) => CartItemCard(item: items[index]),
    );
  }
}

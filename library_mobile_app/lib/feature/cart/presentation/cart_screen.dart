import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/data/model/book_model.dart';
import 'package:library_mobile_app/feature/cart/presentation/widgets/cart_item.dart';
import 'package:library_mobile_app/feature/payment_page/data/payment_mode.dart';
import 'package:library_mobile_app/feature/payment_page/presentation/payment_screen.dart';
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
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final accent = AppColors.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            localizations.shoppingCart,
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: bgColor,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: accent,
            labelColor: accent,
            unselectedLabelColor: secondaryText,
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
              final Map<String, CartItemModel> uniqueBuyingMap = {};
              for (var item in state.cart.details.where(
                (item) => item.type != 'borrow',
              )) {
                uniqueBuyingMap['${item.bookId}_${item.type}'] = item;
              }
              final buyingItems = uniqueBuyingMap.values.toList();

              final Map<String, CartItemModel> uniqueBorrowingMap = {};
              for (var item in state.cart.details.where(
                (item) => item.type == 'borrow',
              )) {
                uniqueBorrowingMap['${item.bookId}_${item.type}'] = item;
              }
              final borrowingItems = uniqueBorrowingMap.values.toList();

              final bool isCartEmpty = state.cart.details.isEmpty;

              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCartList(
                          buyingItems,
                          state.cart.details,
                          isDark,
                          localizations,
                          'buying_list',
                          cardColor,
                          secondaryText,
                          accent,
                        ),
                        _buildCartList(
                          borrowingItems,
                          state.cart.details,
                          isDark,
                          localizations,
                          'borrowing_list',
                          cardColor,
                          secondaryText,
                          accent,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 125, top: 10),
                    child: _buildConfirmButton(
                      context,
                      isDark,
                      isCartEmpty,
                      localizations,
                      state,
                      cardColor,
                      accent,
                    ),
                  ),
                ],
              );
            }
            return Center(child: CircularProgressIndicator(color: accent));
          },
        ),
      ),
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    bool isDark,
    bool isCartEmpty,
    AppLocalizations localizations,
    CartState state,
    Color cardColor,
    Color accent,
  ) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.72,
        height: 56,
        child: Material(
          color: Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: accent, width: 1.6)),
          elevation: 8,
          shadowColor: accent.withOpacity(0.3),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () {
              if (isCartEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Sorry, your cart is completely empty. The order can't be completed.",
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }

              List<CheckoutItemModel> finalCheckoutItems = [];
              if (state is CartLoaded) {
                final Map<String, int> counts = {};
                for (var item in state.cart.details) {
                  final key = '${item.bookId}_${item.type}';
                  counts[key] = (counts[key] ?? 0) + 1;
                }

                final Map<String, CheckoutItemModel> uniqueMap = {};
                for (var item in state.cart.details) {
                  final key = '${item.bookId}_${item.type}';
                  if (!uniqueMap.containsKey(key)) {
                    uniqueMap[key] = CheckoutItemModel(
                      bookId: item.bookId,
                      quantity: counts[key] ?? 1,
                    );
                  }
                }
                finalCheckoutItems = uniqueMap.values.toList();
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CheckoutScreen(cartItems: finalCheckoutItems),
                ),
              );
            },
            child: Ink(
              decoration: ShapeDecoration(
                color: cardColor,
                shape: StadiumBorder(
                  side: BorderSide(color: accent, width: 1.6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, color: accent, size: 19),
                  const SizedBox(width: 9),
                  Text(
                    localizations.confirmOrderAndPay,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: accent,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartList(
    List<dynamic> items,
    List<CartItemModel> allCartItems,
    bool isDark,
    AppLocalizations localizations,
    String listKey,
    Color cardColor,
    Color secondaryText,
    Color accent,
  ) {
    if (items.isEmpty) {
      return Center(
        key: ValueKey('${listKey}_empty'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: accent.withOpacity(0.3),
            ),
            const SizedBox(height: 14),
            Text(
              localizations.noItemsInSection,
              style: TextStyle(
                color: secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      key: ValueKey(listKey),
      padding: const EdgeInsets.only(bottom: 20, top: 15, left: 10, right: 10),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          CartItemCard(item: items[index], allCartItems: allCartItems),
    );
  }
}

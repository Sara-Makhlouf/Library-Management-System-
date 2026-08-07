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
                    padding: const EdgeInsets.only(bottom: 125, top: 10),
                    child: _buildConfirmButton(
                      context,
                      isDark,
                      isCartEmpty,
                      localizations,
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

  Widget _buildConfirmButton(
    BuildContext context,
    bool isDark,
    bool isCartEmpty,
    AppLocalizations localizations,
  ) {
    final fillColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark
        ? AppColors.primary
        : const Color.fromARGB(255, 96, 82, 50);
    final contentColor = isDark
        ? AppColors.primary
        : const Color.fromARGB(255, 96, 82, 50);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.72,
        height: 56,
        child: Material(
          color: Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(color: borderColor, width: 1.6),
          ),
          elevation: 8,
          shadowColor: borderColor.withOpacity(0.3),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () {
              if (isCartEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Sorry, your cart is completely empty. The order can't be completed.",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pushNamed(
                context,
                Routes.payment,
                arguments: context.read<CartBloc>(),
              );
            },
            child: Ink(
              decoration: ShapeDecoration(
                color: fillColor,
                shape: StadiumBorder(
                  side: BorderSide(color: borderColor, width: 1.6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: contentColor,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    localizations.confirmOrderAndPay,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
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

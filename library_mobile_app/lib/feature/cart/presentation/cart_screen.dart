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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<CartBloc>().add(LoadCartEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    final accent = AppColors.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,

        // ==========================================================
        // BODY
        // ==========================================================
        body: SafeArea(
          child: Column(
            children: [
              // ======================================================
              // HEADER
              // ======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: accent,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.shoppingCart,
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            'Review your selected books',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ======================================================
              // TABS
              // ======================================================
              Container(
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,

                  indicator: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(13),
                  ),

                  indicatorSize: TabBarIndicatorSize.tab,

                  labelColor: Colors.white,
                  unselectedLabelColor: secondaryText,

                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),

                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),

                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 17),

                          const SizedBox(width: 7),

                          Text(localizations.buyingTab),
                        ],
                      ),
                    ),

                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 17),

                          const SizedBox(width: 7),

                          Text(localizations.borrowingTab),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ======================================================
              // CART CONTENT
              // ======================================================
              Expanded(
                child: BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    // ==================================================
                    // LOADING
                    // ==================================================
                    if (state is CartLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: accent),
                      );
                    }

                    // ==================================================
                    // ERROR
                    // ==================================================
                    if (state is CartError) {
                      return _buildError(context, state, accent, secondaryText);
                    }

                    // ==================================================
                    // NOT LOADED
                    // ==================================================
                    if (state is! CartLoaded) {
                      return Center(
                        child: CircularProgressIndicator(color: accent),
                      );
                    }

                    // ==================================================
                    // BUYING
                    // ==================================================
                    final buyingItems = _uniqueItems(
                      state.cart.details
                          .where((item) => item.type != 'borrow')
                          .toList(),
                    );

                    // ==================================================
                    // BORROWING
                    // ==================================================
                    final borrowingItems = _uniqueItems(
                      state.cart.details
                          .where((item) => item.type == 'borrow')
                          .toList(),
                    );

                    // ==================================================
                    // TAB VIEW
                    // ==================================================
                    return TabBarView(
                      children: [
                        _buildCartList(
                          items: buyingItems,
                          allCartItems: state.cart.details,
                          isDark: isDark,
                          accent: accent,
                          secondaryText: secondaryText,
                          localizations: localizations,
                        ),

                        _buildCartList(
                          items: borrowingItems,
                          allCartItems: state.cart.details,
                          isDark: isDark,
                          accent: accent,
                          secondaryText: secondaryText,
                          localizations: localizations,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ==========================================================
        // CHECKOUT
        //
        // مهم:
        // نقلناه من داخل Column إلى bottomNavigationBar
        // حتى ما يصير RenderFlex overflow.
        // ==========================================================
        bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is! CartLoaded) {
              return const SizedBox.shrink();
            }

            return _buildCheckout(context, state, accent, localizations);
          },
        ),
      ),
    );
  }

  // ==============================================================
  // CART LIST
  // ==============================================================

  Widget _buildCartList({
    required List<CartItemModel> items,
    required List<CartItemModel> allCartItems,
    required bool isDark,
    required Color accent,
    required Color secondaryText,
    required AppLocalizations localizations,
  }) {
    // ============================================================
    // EMPTY
    // ============================================================

    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 42,
                  color: accent.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                localizations.noItemsInSection,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Add books to your cart and they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ============================================================
    // LIST
    // ============================================================

    return ListView.builder(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),

      itemCount: items.length,

      itemBuilder: (context, index) {
        final item = items[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CartItemCard(item: item, allCartItems: allCartItems),
        );
      },
    );
  }

  // ==============================================================
  // CHECKOUT BUTTON
  // ==============================================================

  Widget _buildCheckout(
    BuildContext context,
    CartLoaded state,
    Color accent,
    AppLocalizations localizations,
  ) {
    final isEmpty = state.cart.details.isEmpty;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 14 + bottomPadding),

      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: SizedBox(
        width: double.infinity,
        height: 54,

        child: ElevatedButton(
          onPressed: () {
            if (isEmpty) {
              _showEmptyMessage(context);
              return;
            }

            _openCheckout(context, state);
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: isEmpty ? accent.withOpacity(0.35) : accent,

            foregroundColor: Colors.white,

            elevation: isEmpty ? 0 : 4,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 19),

              const SizedBox(width: 9),

              Flexible(
                child: Text(
                  localizations.confirmOrderAndPay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 7),

              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // CHECKOUT
  // ==============================================================

  void _openCheckout(BuildContext context, CartLoaded state) {
    final Map<String, int> counts = {};

    // ============================================================
    // COUNT ITEMS
    // ============================================================

    for (final item in state.cart.details) {
      final key = '${item.bookId}_${item.type}';

      counts[key] = (counts[key] ?? 0) + 1;
    }

    // ============================================================
    // UNIQUE CHECKOUT ITEMS
    // ============================================================

    final Map<String, CheckoutItemModel> uniqueMap = {};

    for (final item in state.cart.details) {
      final key = '${item.bookId}_${item.type}';

      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = CheckoutItemModel(
          bookId: item.bookId,
          quantity: counts[key] ?? 1,
        );
      }
    }

    // ============================================================
    // NAVIGATE
    // ============================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(cartItems: uniqueMap.values.toList()),
      ),
    );
  }

  // ==============================================================
  // ERROR
  // ==============================================================

  Widget _buildError(
    BuildContext context,
    CartError state,
    Color accent,
    Color secondaryText,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 50,
            ),

            const SizedBox(height: 16),

            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryText, fontSize: 13),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                context.read<CartBloc>().add(LoadCartEvent());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // EMPTY MESSAGE
  // ==============================================================

  void _showEmptyMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shopping_cart_outlined, color: Colors.white),

            SizedBox(width: 10),

            Expanded(child: Text('Your cart is empty.')),
          ],
        ),

        backgroundColor: Colors.redAccent,

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.all(16),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ==============================================================
  // UNIQUE ITEMS
  // ==============================================================

  List<CartItemModel> _uniqueItems(List<CartItemModel> items) {
    final Map<String, CartItemModel> unique = {};

    for (final item in items) {
      final key = '${item.bookId}_${item.type}';

      unique[key] = item;
    }

    return unique.values.toList();
  }
}

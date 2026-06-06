import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_bloc.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_event.dart';
import 'package:library_mobile_app/feature/cart/bloc/cart_state.dart';
import 'package:library_mobile_app/feature/cart/presentation/widgets/cart_item.dart';

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
    // ─── التعديل: فحص حالة الثيم الحالية لتطبيق الألوان الداكنة ديناميكياً ───
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // ─── التعديل: الخلفية تأخذ لونكِ المفضل بالوضع الفاتح وتتحول للداكن المعتمد بالثيم الآخر ───
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFEFE3D3),
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          title: Text(
            "Shopping Cart",
            style: TextStyle(
              color: isDark ? AppColors.textDark : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          // ─── التعديل: خلفية الـ AppBar تتغير حسب الثيم ───
          backgroundColor: isDark
              ? AppColors.darkCard
              : const Color.fromARGB(255, 189, 170, 127),
          bottom: TabBar(
            // ─── التعديل: مواءمة ألوان الـ TabBar والمؤشر لتبرز في السنديان الغامق ───
            indicatorColor: isDark
                ? AppColors.primary
                : const Color.fromARGB(255, 96, 82, 50),
            labelColor: isDark
                ? AppColors.primary
                : const Color.fromARGB(255, 96, 82, 50),
            unselectedLabelColor: isDark ? AppColors.textGrey : Colors.white70,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: "Buying"),
              Tab(text: "Borrowing"),
            ],
          ),
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCartList(
                          state.cartItems
                              .where(
                                (item) => (item.isBorrow ?? false) == false,
                              )
                              .toList(),
                          isDark,
                        ),
                        _buildCartList(
                          state.cartItems
                              .where((item) => (item.isBorrow ?? false) == true)
                              .toList(),
                          isDark,
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
                          // ─── التعديل: زر تأكيد الطلب يتلون ليلائم الدارك مود بأناقة ───
                          backgroundColor: isDark
                              ? AppColors.inputDark
                              : const Color.fromARGB(255, 189, 170, 127),
                          foregroundColor: isDark
                              ? AppColors.primary
                              : const Color.fromARGB(255, 96, 82, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            // إضافة حدود خفيفة في الوضع الداكن لإبراز معالم الزر
                            side: isDark
                                ? BorderSide(
                                    color: AppColors.primary.withOpacity(0.3),
                                  )
                                : BorderSide.none,
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.payment,
                            arguments: context.read<CartBloc>(),
                          );
                        },
                        child: const Text(
                          "Confirm Order & Pay",
                          style: TextStyle(
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

  // ─── التعديل: تمرير الـ isDark لضبط نصوص التنبيهات الفارغة ───
  Widget _buildCartList(List<dynamic> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No items in this section",
          style: TextStyle(
            color: isDark ? AppColors.textGrey : Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20, top: 15, left: 10, right: 10),
      itemCount: items.length,
      itemBuilder: (context, index) => CartItemCard(item: items[index]),
    );
  }
}

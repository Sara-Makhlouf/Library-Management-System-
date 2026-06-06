import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/cart/presentation/cart_screen.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/BottomNav.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/PointsStickyNote.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/category_seation.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/popular_books.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/search_barr.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : const Color(0xFFEFE3D3),
          appBar: state.tabIndex == 1
              ? AppBar(
                  backgroundColor: isDark
                      ? AppColors.backgroundDark
                      : const Color(0xFFEFE3D3),
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    'Home',
                    style: TextStyle(
                      color: isDark ? AppColors.textDark : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: isDark ? AppColors.textDark : Colors.black,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  actions: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.notifications_none,
                          color: isDark
                              ? AppColors.primary
                              : AppColors.secondary,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.notifications);
                        },
                      ),
                    ),
                  ],
                )
              : null,

          drawer: Drawer(
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : const Color(0xFFEFE3D3),
            surfaceTintColor: Colors.transparent,
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.accentDark
                        : const Color(0xFFD8C8A8),
                  ),
                  currentAccountPicture: CircleAvatar(
                    radius: 35,
                    backgroundColor: isDark
                        ? AppColors.inputDark
                        : const Color(0xFF605232),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: isDark
                          ? AppColors.primary
                          : const Color(0xFFF5EFEB),
                    ),
                  ),
                  accountName: Text(
                    'Ghufran Ibrahim',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textDark
                          : const Color(0xFF2C2518),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(
                    'ghufran@example.com',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textGrey
                          : const Color(0xFF605232),
                      fontSize: 14,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.history_edu,
                          color: isDark
                              ? AppColors.primary
                              : const Color(0xFF605232),
                        ),
                        title: Text(
                          'Order history',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDark
                                : const Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isDark
                              ? AppColors.textGrey
                              : const Color(0xFF605232),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.local_shipping_outlined,
                          color: isDark
                              ? AppColors.primary
                              : const Color(0xFF605232),
                        ),
                        title: Text(
                          'Delivery',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDark
                                : const Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isDark
                              ? AppColors.textGrey
                              : const Color(0xFF605232),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.card_giftcard,
                          color: isDark
                              ? AppColors.primary
                              : const Color(0xFF605232),
                        ),
                        title: Text(
                          'Profile',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDark
                                : const Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isDark
                              ? AppColors.textGrey
                              : const Color(0xFF605232),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(Routes.profile);
                        },
                      ),

                      Divider(
                        color: isDark
                            ? AppColors.accentDark
                            : const Color(0xFFD8C8A8),
                        thickness: 1,
                        indent: 15,
                        endIndent: 15,
                      ),

                      ListTile(
                        leading: Icon(
                          Icons.settings_outlined,
                          color: isDark
                              ? AppColors.primary
                              : const Color(0xFF605232),
                        ),
                        title: Text(
                          'Settings',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDark
                                : const Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, Routes.settings);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          color: isDark
                              ? AppColors.primary
                              : const Color(0xFF605232),
                        ),
                        title: Text(
                          'Contact us',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDark
                                : const Color(0xFF2C2518),
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                Divider(
                  color: isDark
                      ? AppColors.accentDark
                      : const Color(0xFFD8C8A8),
                  thickness: 1,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: const Icon(Icons.logout, color: Color(0xFFB33A3A)),
                  title: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Color(0xFFB33A3A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          body: buildBody(state.tabIndex, isDark),
          bottomNavigationBar: BottomNav(
            currentIndex: state.tabIndex,
            onTap: (index) {
              context.read<HomeBloc>().add(ChangeTabEvent(index));
            },
          ),
        );
      },
    );
  }

  Widget buildBody(int state, bool isDark) {
    switch (state) {
      case 0:
        return Center(
          child: Text(
            "Favourite Page",
            style: TextStyle(
              color: isDark ? AppColors.textDark : Colors.black87,
            ),
          ),
        );

      case 1:
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Search(),
                    const Positioned(
                      right: 15,
                      top: 40,
                      child: PointsStickyNote(points: 150),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 65),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Most popular",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.primary
                          : const Color(0xFF685A39),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: PopularBooksSlider(),
              ),

              const SizedBox(height: 20),
              const BookCategoriesSection(),

              const SizedBox(height: 100),
            ],
          ),
        );
      case 2:
        return const CartScreen();
      default:
        return Center(
          child: Text(
            "Home",
            style: TextStyle(
              color: isDark ? AppColors.textDark : Colors.black87,
            ),
          ),
        );
    }
  }
}

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
import 'package:library_mobile_app/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) => previous.tabIndex != current.tabIndex,
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
                    localizations.home,
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
                  actions: [CustomNotificationButton()],
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
                  accountName: const Text(
                    'Ghufran Ibrahim',
                    style: TextStyle(
                      color: Color(0xFF2C2518),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: const Text(
                    'ghufran@example.com',
                    style: TextStyle(color: Color(0xFF605232), fontSize: 14),
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
                          localizations.orderHistory,
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
                          localizations.deliveryService,
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
                          localizations.profile,
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
                          localizations.settings,
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
                          localizations.contactUs,
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
                  title: Text(
                    localizations.logout,
                    style: const TextStyle(
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

          body: buildBody(state.tabIndex, isDark, localizations),
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

  Widget buildBody(int tabIndex, bool isDark, AppLocalizations localizations) {
    switch (tabIndex) {
      case 0:
        return Center(
          child: Text(
            localizations.favouritePage,
            style: TextStyle(
              color: isDark ? AppColors.textDark : Colors.black87,
            ),
          ),
        );

      case 1:
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.searchStatus != current.searchStatus ||
              previous.searchQuery != current.searchQuery ||
              previous.searchBooks != current.searchBooks,
          builder: (context, state) {
            final bool hasSearchQuery = state.searchQuery.trim().isNotEmpty;

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

                        if (!hasSearchQuery)
                          const Positioned(
                            right: 15,
                            top: 40,
                            child: PointsStickyNote(points: 150),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: hasSearchQuery ? 20 : 65),
                  if (state.searchStatus == HomeStatus.loading &&
                      hasSearchQuery)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (hasSearchQuery)
                    state.searchBooks.isEmpty &&
                            state.searchStatus == HomeStatus.loaded
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30.0),
                              child: Text('', style: TextStyle(fontSize: 16)),
                            ),
                          )
                        : const SizedBox.shrink()
                  else
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              localizations.mostPopular,
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
                      ],
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        );
      case 2:
        return const CartScreen();
      default:
        return Center(
          child: Text(
            localizations.home,
            style: TextStyle(
              color: isDark ? AppColors.textDark : Colors.black87,
            ),
          ),
        );
    }
  }
}

class CustomNotificationButton extends StatelessWidget {
  const CustomNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 50,
      height: 50,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.notifications_none,
          color: isDark ? AppColors.primary : AppColors.secondary,
          size: 30,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.notifications);
        },
      ),
    );
  }
}

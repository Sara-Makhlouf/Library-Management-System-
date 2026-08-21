import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/constantPage.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/Bill/presentation/AllBillsScreen.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestBloc.dart';
import 'package:library_mobile_app/feature/BookRequest/data/BookRequestRepository.dart';
import 'package:library_mobile_app/feature/BookRequest/presentation/BookRequestsScreen.dart';
import 'package:library_mobile_app/feature/cart/presentation/cart_screen.dart';
import 'package:library_mobile_app/feature/favourite/presentation/favourit_screen.dart';
import 'package:library_mobile_app/feature/homepage/bloc/home_bloc.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/BottomNav.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/PointsStickyNote.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/category_seation.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/popular_books.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/search_barr.dart';
import 'package:library_mobile_app/feature/profile/data/customer_repository.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _customerRepository = CustomerRepository();

  String _userName = '';
  String _userEmail = '';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final result = await _customerRepository.getProfile();
      final data = result['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _userName = data['name'] ?? '';
        _userEmail = data['email'] ?? '';
        _avatarUrl = data['avatar'];
      });
    } catch (e) {
      debugPrint('🔴 فشل جلب بيانات المستخدم للدروار: $e');
    }
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1);
    return parts.first.substring(0, 1) + parts[1].substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final accent = AppColors.primary;

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) => previous.tabIndex != current.tabIndex,
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          backgroundColor: bgColor,
          appBar: state.tabIndex == 1
              ? AppBar(
                  backgroundColor: bgColor,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    localizations.home,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: primaryText),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  actions: [CustomNotificationButton()],
                )
              : null,
          drawer: _buildDrawer(
            context,
            isDark,
            localizations,
            primaryText,
            secondaryText,
            accent,
            bgColor,
          ),
          body: buildBody(state.tabIndex, isDark, localizations),
          bottomNavigationBar: SafeArea(
            child: BottomNav(
              currentIndex: state.tabIndex,
              onTap: (index) {
                context.read<HomeBloc>().add(ChangeTabEvent(index));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    bool isDark,
    AppLocalizations localizations,
    Color primaryText,
    Color secondaryText,
    Color accent,
    Color bgColor,
  ) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);
    final headerBg = isDark ? AppColors.darkCard : const Color(0xFFD8C8A8);

    return Drawer(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: headerBg),
            currentAccountPicture: _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 33,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(_avatarUrl!),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent, accent.withOpacity(0.7)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 33,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        _getInitials(_userName),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.backgroundDark
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
            accountName: Text(
              _userName.isEmpty ? '...' : _userName,
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              _userEmail,
              style: TextStyle(color: secondaryText, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  icon: Icons.receipt_long,
                  title: "My Bills",
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllBillsScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.library_add_check_outlined,
                  title: "Book Requests",
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => BookRequestBloc(
                            repository: BookRequestRepository(),
                          ),
                          child: const BookRequestsScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.history_edu,
                  title: localizations.orderHistory,
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.orderHistory);
                  },
                ),
                _drawerItem(
                  icon: Icons.hourglass_empty_rounded,
                  title: 'Waiting List',
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.myWaitingList);
                  },
                ),
                /* _drawerItem(
                  icon: Icons.local_shipping_outlined,
                  title: localizations.deliveryService,
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),*/
                _drawerItem(
                  icon: Icons.person_outline,
                  title: localizations.profile,
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.of(context).pushNamed(Routes.profile);
                    _loadUserData();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Divider(color: borderColor, thickness: 1),
                ),
                _drawerItem(
                  icon: Icons.settings_outlined,
                  title: localizations.settings,
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () {
                    Navigator.pushNamed(context, Routes.settings);
                  },
                ),
                _drawerItem(
                  icon: Icons.chat_bubble_outline,
                  title: localizations.contactUs,
                  accent: accent,
                  primaryText: primaryText,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Divider(color: borderColor, thickness: 1),
          _drawerItem(
            icon: Icons.logout,
            title: localizations.logout,
            accent: const Color(0xFFB33A3A),
            primaryText: const Color(0xFFB33A3A),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required Color accent,
    required Color primaryText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: accent, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: primaryText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: primaryText.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }

  Widget buildBody(int tabIndex, bool isDark, AppLocalizations localizations) {
    switch (tabIndex) {
      case 0:
        return const FavoriteScreen();
      case 1:
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.searchStatus != current.searchStatus ||
              previous.searchQuery != current.searchQuery ||
              previous.searchBooks != current.searchBooks ||
              previous.status != current.status ||
              previous.popularBooks != current.popularBooks ||
              previous.categoriesStatus != current.categoriesStatus ||
              previous.categories != current.categories ||
              previous.booksStatus != current.booksStatus ||
              previous.categoryBooks != current.categoryBooks,
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
                          Positioned(
                            right: 15,
                            top: 40,
                            child: PointsStickyNote(),
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

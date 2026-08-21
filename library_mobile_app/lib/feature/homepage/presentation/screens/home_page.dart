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
import 'package:library_mobile_app/feature/homepage/presentation/screens/contactus.dart';
import 'package:library_mobile_app/feature/homepage/presentation/screens/help&support.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/BottomNav.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/PointsStickyNote.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/category_seation.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/popular_books.dart';
import 'package:library_mobile_app/feature/homepage/presentation/widgets/search_barr.dart';

import 'package:library_mobile_app/feature/profile/data/customer_repository.dart';

import 'package:library_mobile_app/feature/notifications/bloc/notification_cubit.dart';
import 'package:library_mobile_app/feature/notifications/bloc/notification_state.dart';
import 'package:library_mobile_app/feature/notifications/repo/notification_repository.dart';

import 'package:library_mobile_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();

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
        _userName = data['name']?.toString() ?? '';
        _userEmail = data['email']?.toString() ?? '';
        _avatarUrl = data['avatar']?.toString();
      });
    } catch (e) {
      debugPrint('🔴 Failed to load user data for drawer: $e');
    }
  }

  String _getInitials(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationCubit>(
          create: (_) =>
              NotificationCubit(NotificationRepository())..getNotifications(),
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) => previous.tabIndex != current.tabIndex,
        builder: (context, state) {
          return Scaffold(
            extendBody: true,
            backgroundColor: bgColor,

            // =========================================================
            // APP BAR
            // =========================================================
            appBar: state.tabIndex == 1
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(68),
                    child: _buildHomeAppBar(
                      context: context,
                      isDark: isDark,
                      primaryText: primaryText,
                      bgColor: bgColor,
                    ),
                  )
                : null,

            // =========================================================
            // DRAWER
            // =========================================================
            drawer: _buildDrawer(
              context,
              isDark,
              localizations,
              primaryText,
              secondaryText,
              accent,
              bgColor,
            ),

            // =========================================================
            // BODY
            // =========================================================
            body: buildBody(state.tabIndex, isDark, localizations),

            // =========================================================
            // BOTTOM NAVIGATION
            // =========================================================
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
      ),
    );
  }

  // ================================================================
  // HOME APP BAR
  // ================================================================

  Widget _buildHomeAppBar({
    required BuildContext context,
    required bool isDark,
    required Color primaryText,
    required Color bgColor,
  }) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,

      titleSpacing: 16,

      title: Row(
        children: [
          // =========================================================
          // MENU BUTTON
          // =========================================================
          Builder(
            builder: (context) {
              return _AppBarIconButton(
                icon: Icons.menu_rounded,
                isDark: isDark,
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),

          const SizedBox(width: 12),

          // =========================================================
          // TITLE
          // =========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hibr & Waraq',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your digital library',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // NOTIFICATION
          // =========================================================
          const CustomNotificationButton(),
        ],
      ),
    );
  }

  // ================================================================
  // DRAWER
  // ================================================================

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

      child: SafeArea(
        child: Column(
          children: [
            // =======================================================
            // PROFILE HEADER
            // =======================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      _buildDrawerAvatar(isDark: isDark, accent: accent),

                      const SizedBox(width: 14),

                      // User information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName.isEmpty ? 'Loading...' : _userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Profile button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);

                        await Navigator.of(context).pushNamed(Routes.profile);

                        if (mounted) {
                          _loadUserData();
                        }
                      },
                      icon: Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: accent,
                      ),
                      label: Text(
                        localizations.profile,
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent.withOpacity(0.35)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =======================================================
            // MENU
            // =======================================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                children: [
                  _drawerSectionTitle('Library', primaryText),

                  _drawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'My Bills',
                    accent: accent,
                    primaryText: primaryText,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllBillsScreen(),
                        ),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.library_add_check_outlined,
                    title: 'Book Requests',
                    accent: accent,
                    primaryText: primaryText,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => BookRequestBloc(
                              repository: BookRequestRepository(),
                            ),
                            child: const BookRequestsScreen(),
                          ),
                        ),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.history_edu_rounded,
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

                  const SizedBox(height: 12),

                  _drawerSectionTitle('Account', primaryText),

                  _drawerItem(
                    icon: Icons.settings_outlined,
                    title: localizations.settings,
                    accent: accent,
                    primaryText: primaryText,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(context, Routes.settings);
                    },
                  ),

                  _drawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: localizations.contactUs,
                    accent: accent,
                    primaryText: primaryText,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // =======================================================
            // HELP & SUPPORT
            // =======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              child: Column(
                children: [
                  Divider(color: borderColor, thickness: 1, height: 1),

                  const SizedBox(height: 10),

                  _drawerItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    accent: accent,
                    primaryText: primaryText,
                    showArrow: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutLibraryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // DRAWER AVATAR
  // ================================================================

  Widget _buildDrawerAvatar({required bool isDark, required Color accent}) {
    if (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: accent.withOpacity(0.15),
        backgroundImage: NetworkImage(_avatarUrl!),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withOpacity(0.65)],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(_userName),
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.backgroundDark : Colors.white,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DRAWER SECTION TITLE
  // ================================================================

  Widget _drawerSectionTitle(String title, Color primaryText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: primaryText.withOpacity(0.45),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ================================================================
  // DRAWER ITEM
  // ================================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required Color accent,
    required Color primaryText,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: primaryText.withOpacity(0.3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BODY
  // ================================================================

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
            final hasSearchQuery = state.searchQuery.trim().isNotEmpty;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (hasSearchQuery)
                    state.searchBooks.isEmpty &&
                            state.searchStatus == HomeStatus.loaded
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Text(
                                'No books found',
                                style: TextStyle(fontSize: 16),
                              ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              localizations.mostPopular,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.primary
                                    : const Color(0xFF685A39),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: PopularBooksSlider(),
                        ),

                        const SizedBox(height: 24),

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

// ====================================================================
// APP BAR ICON BUTTON
// ====================================================================

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Icon(
            icon,
            size: 23,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// NOTIFICATION BUTTON
// ====================================================================

class CustomNotificationButton extends StatelessWidget {
  const CustomNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconColor = isDark ? AppColors.primary : AppColors.secondary;

    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (previous, current) {
        if (previous is NotificationLoaded && current is NotificationLoaded) {
          return previous.unreadCount != current.unreadCount;
        }

        return true;
      },
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ======================================================
              // BUTTON
              // ======================================================
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    await Navigator.of(context).pushNamed(Routes.notifications);

                    if (!context.mounted) {
                      return;
                    }

                    // تحديث العدد فقط بعد الرجوع
                    context.read<NotificationCubit>().refreshUnreadCount();
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        unreadCount > 0
                            ? Icons.notifications_rounded
                            : Icons.notifications_none_rounded,
                        key: ValueKey(unreadCount > 0),
                        color: iconColor,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),

              // ======================================================
              // RED BADGE
              // ======================================================
              if (unreadCount > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.backgroundDark
                              : AppColors.backgroundLight,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.16),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

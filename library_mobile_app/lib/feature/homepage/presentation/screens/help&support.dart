import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class AboutLibraryScreen extends StatelessWidget {
  const AboutLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white60 : AppColors.textGrey;

    final accent = AppColors.primary;

    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,

        title: Text(
          'About Library',
          style: TextStyle(
            color: primaryText,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),

        iconTheme: IconThemeData(color: primaryText),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),

        child: Column(
          children: [
            // =====================================================
            // APP HEADER
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),

              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
              ),

              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,

                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(24),
                    ),

                    child: Icon(
                      Icons.menu_book_rounded,
                      color: accent,
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Hibr & Waraq',
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Your digital library',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ABOUT
            // =====================================================
            _section(
              title: 'About Hibr & Waraq',
              icon: Icons.info_outline_rounded,
              accent: accent,
              primaryText: primaryText,
              secondaryText: secondaryText,
              cardColor: cardColor,
              borderColor: borderColor,

              child: Text(
                'Hibr & Waraq is a digital library platform designed '
                'to make discovering, borrowing and purchasing books '
                'simple and convenient. Explore the library, save your '
                'favourite books and manage your orders all in one place.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // FEATURES
            // =====================================================
            _section(
              title: 'What you can do',
              icon: Icons.auto_awesome_rounded,
              accent: accent,
              primaryText: primaryText,
              secondaryText: secondaryText,
              cardColor: cardColor,
              borderColor: borderColor,

              child: Column(
                children: [
                  _featureItem(
                    icon: Icons.search_rounded,
                    title: 'Discover Books',
                    subtitle: 'Browse and find books easily.',
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),

                  _featureItem(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Save Favourites',
                    subtitle: 'Keep your favourite books in one place.',
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),

                  _featureItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Buy & Borrow',
                    subtitle: 'Purchase or borrow available books.',
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),

                  _featureItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Track Orders',
                    subtitle: 'View your orders and invoices.',
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // LIBRARY INFO
            // =====================================================
            _section(
              title: 'Library Information',
              icon: Icons.library_books_outlined,
              accent: accent,
              primaryText: primaryText,
              secondaryText: secondaryText,
              cardColor: cardColor,
              borderColor: borderColor,

              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.access_time_rounded,
                    title: 'Opening Hours',
                    value: '08:00 AM - 06:00 PM',
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),

                  _infoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    value: 'University Library',
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),

                  _infoRow(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: 'info@hibrwaraq.com',
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Made with ♥ for book lovers',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
    required Color cardColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),

              const SizedBox(width: 9),

              Text(
                title,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  Widget _featureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(icon, color: accent, size: 19),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(color: secondaryText, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Icon(icon, color: accent, size: 19),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              title,
              style: TextStyle(color: secondaryText, fontSize: 12),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

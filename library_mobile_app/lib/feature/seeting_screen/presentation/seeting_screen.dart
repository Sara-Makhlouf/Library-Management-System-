import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme_cubit.dart';
import 'package:library_mobile_app/core/locale_cubit.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/login/presentation/signin_screen.dart';
import 'package:library_mobile_app/feature/logout/bloc/logout_bloc.dart';
import 'package:library_mobile_app/feature/logout/bloc/logout_event.dart';
import 'package:library_mobile_app/feature/logout/bloc/logout_state.dart';
import 'package:library_mobile_app/feature/logout/repo/logout_repo.dart';
import 'package:library_mobile_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;

  static const String _appVersion = '1.0.0';

  late final LogoutBloc _logoutBloc = LogoutBloc(
    repository: LogoutRepository(),
  );

  @override
  void dispose() {
    _logoutBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionLabel('Account', isDark),
          const SizedBox(height: 8),
          _buildCard(isDark, [
            _buildSettingsTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Account',
              isDark: isDark,
              labelColor: const Color(0xFFB33A3A),
              iconColor: const Color(0xFFB33A3A),
              trailing: _chevron(isDark),
              onTap: () => _showDeleteAccountDialog(isDark),
            ),
          ]),

          const SizedBox(height: 26),

          _buildSectionLabel('Notifications', isDark),
          const SizedBox(height: 8),
          _buildCard(isDark, [
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              isDark: isDark,
              trailing: Switch(
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
                activeColor: AppColors.primary,
              ),
            ),
          ]),

          const SizedBox(height: 26),

          _buildSectionLabel('General', isDark),
          const SizedBox(height: 8),
          _buildCard(isDark, [
            _buildSettingsTile(
              icon: isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              label: isDark
                  ? AppLocalizations.of(context)!.darkMode
                  : AppLocalizations.of(context)!.lightMode,
              isDark: isDark,
              trailing: Switch(
                value: isDark,
                onChanged: (bool value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                activeColor: AppColors.primary,
              ),
            ),
            _divider(isDark),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              label: 'App Language',
              isDark: isDark,
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLocale.languageCode,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<LocaleCubit>().changeLanguage(newValue);
                    }
                  },
                ),
              ),
            ),
          ]),

          const SizedBox(height: 26),

          _buildSectionLabel('Support', isDark),
          const SizedBox(height: 8),
          _buildCard(isDark, [
            _buildSettingsTile(
              icon: Icons.help_outline_rounded,
              label: 'Help Center & FAQ',
              isDark: isDark,
              trailing: _chevron(isDark),
              onTap: () => _showFaqSheet(isDark),
            ),
            _divider(isDark),
            _buildSettingsTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Contact Us',
              isDark: isDark,
              trailing: _chevron(isDark),
              onTap: () => _showContactSheet(isDark),
            ),
            _divider(isDark),
            _buildSettingsTile(
              icon: Icons.star_outline_rounded,
              label: 'Rate the App',
              isDark: isDark,
              trailing: _chevron(isDark),
              onTap: () => _showRateAppDialog(isDark),
            ),
          ]),

          const SizedBox(height: 26),

          _buildSectionLabel('About', isDark),
          const SizedBox(height: 8),
          _buildCard(isDark, [
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'App Version',
              isDark: isDark,
              trailing: Text(
                _appVersion,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.5)
                      : AppColors.textLight.withOpacity(0.5),
                ),
              ),
            ),
            _divider(isDark),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              label: 'Terms & Conditions',
              isDark: isDark,
              trailing: _chevron(isDark),
              onTap: () => _showTextSheet(
                isDark,
                title: 'Terms & Conditions',
                body:
                    'By using this app you agree to borrow and purchase books responsibly, return borrowed items on time, and keep your account information accurate. Full terms will be published here once finalized.',
              ),
            ),
            _divider(isDark),
            _buildSettingsTile(
              icon: Icons.policy_outlined,
              label: 'Privacy Policy',
              isDark: isDark,
              trailing: _chevron(isDark),
              onTap: () => _showTextSheet(
                isDark,
                title: 'Privacy Policy',
                body:
                    'We only collect the information needed to manage your account, orders, and borrowed books. Your data is never sold to third parties. Full policy will be published here once finalized.',
              ),
            ),
          ]),

          const SizedBox(height: 26),

          _buildCard(isDark, [
            _buildSettingsTile(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              isDark: isDark,
              labelColor: const Color(0xFFB33A3A),
              iconColor: const Color(0xFFB33A3A),
              onTap: () => _showLogoutDialog(isDark),
            ),
          ]),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showRateAppDialog(bool isDark) {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Rate the App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How was your experience with the app?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textDark.withOpacity(0.6)
                          : AppColors.textLight.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isFilled = starIndex <= selectedStars;
                      return IconButton(
                        onPressed: () {
                          setDialogState(() => selectedStars = starIndex);
                        },
                        icon: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFilled
                              ? Colors.amber
                              : (isDark
                                    ? AppColors.textDark.withOpacity(0.3)
                                    : AppColors.textLight.withOpacity(0.3)),
                          size: 34,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textDark.withOpacity(0.6)
                          : AppColors.textLight.withOpacity(0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selectedStars == 0
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Thanks for your $selectedStars-star rating!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showContactSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.accentDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.email_outlined, color: AppColors.primary),
                title: Text(
                  'support@library-app.com',
                  style: TextStyle(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.phone_outlined, color: AppColors.primary),
                title: Text(
                  '+963 000 000 000',
                  style: TextStyle(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.chat_outlined, color: AppColors.primary),
                title: Text(
                  'Live chat with support',
                  style: TextStyle(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFaqSheet(bool isDark) {
    final faqs = [
      (
        'How do I borrow a book?',
        'Add the book to your cart from its details page, choose "Borrow" instead of "Buy", then confirm your order at checkout.',
      ),
      (
        'How long can I keep a borrowed book?',
        'Borrowing periods vary by title and are shown on the book\'s details page before you confirm your order.',
      ),
      (
        'Can I pay cash on delivery?',
        'Yes, cash on delivery is available alongside online card payment at checkout.',
      ),
      (
        'How do I track my order?',
        'Open the drawer menu and go to Order History to see the status of all your past and current orders.',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.accentDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Help Center & FAQ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              ...faqs.map(
                (faq) => ExpansionTile(
                  iconColor: AppColors.primary,
                  collapsedIconColor: isDark
                      ? AppColors.textDark.withOpacity(0.5)
                      : AppColors.textLight.withOpacity(0.5),
                  title: Text(
                    faq.$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        faq.$2,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textDark.withOpacity(0.6)
                              : AppColors.textLight.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextSheet(
    bool isDark, {
    required String title,
    required String body,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.accentDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.7)
                      : AppColors.textLight.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete your account, order history, and borrowed book records. This action cannot be undone.',
          style: TextStyle(
            color: isDark
                ? AppColors.textDark.withOpacity(0.7)
                : AppColors.textLight.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB33A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: _logoutBloc,
        child: BlocConsumer<LogoutBloc, LogoutState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.pop(dialogContext);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SigninScreen()),
              );
            }
            if (state is LogoutFailure) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LogoutLoading;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Are you sure you want to log out of your account?',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textDark.withOpacity(0.7)
                      : AppColors.textLight.withOpacity(0.7),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB33A3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () => context.read<LogoutBloc>().add(LogoutRequested()),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Log Out'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textDark.withOpacity(0.55)
              : AppColors.textLight.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
    );
  }

  Widget _chevron(bool isDark) {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 14,
      color: isDark
          ? AppColors.textDark.withOpacity(0.35)
          : AppColors.textLight.withOpacity(0.35),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
    Color? labelColor,
    Color? iconColor,
  }) {
    final color =
        labelColor ?? (isDark ? AppColors.textDark : AppColors.textLight);
    final iColor = iconColor ?? color;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 15, color: iColor.withOpacity(0.75)),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: trailing,
    );
  }
}

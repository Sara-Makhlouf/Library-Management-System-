import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:library_mobile_app/core/locale_cubit.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/core/theme_cubit.dart';

import 'package:library_mobile_app/feature/login/presentation/signin_screen.dart';

import 'package:library_mobile_app/feature/logout/bloc/logout_bloc.dart';
import 'package:library_mobile_app/feature/logout/bloc/logout_event.dart';
import 'package:library_mobile_app/feature/logout/bloc/logout_state.dart';
import 'package:library_mobile_app/feature/logout/repo/logout_repo.dart';

import 'package:library_mobile_app/feature/seeting_screen/deletaccount/bloc/delete_bloc.dart';
import 'package:library_mobile_app/feature/seeting_screen/deletaccount/bloc/delete_event.dart';
import 'package:library_mobile_app/feature/seeting_screen/deletaccount/bloc/delete_state.dart';
import 'package:library_mobile_app/feature/seeting_screen/deletaccount/repo/delete_repo.dart';

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

  late final DeleteAccountBloc _deleteAccountBloc = DeleteAccountBloc(
    repository: DeleteAccountRepository(),
  );

  @override
  void dispose() {
    _logoutBloc.close();
    _deleteAccountBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          localizations.settings,
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
          // ============================================================
          // ACCOUNT
          // ============================================================
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

          // ============================================================
          // NOTIFICATIONS
          // ============================================================
          _buildSectionLabel('Notifications', isDark),
          const SizedBox(height: 8),

          _buildCard(isDark, [
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              isDark: isDark,
              trailing: Switch(
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ),
          ]),

          const SizedBox(height: 26),

          // ============================================================
          // GENERAL
          // ============================================================
          _buildSectionLabel('General', isDark),
          const SizedBox(height: 8),

          _buildCard(isDark, [
            _buildSettingsTile(
              icon: isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              label: isDark ? localizations.darkMode : localizations.lightMode,
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
                  icon: const Icon(
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
                  onChanged: (String? value) {
                    if (value != null) {
                      context.read<LocaleCubit>().changeLanguage(value);
                    }
                  },
                ),
              ),
            ),
          ]),

          const SizedBox(height: 26),

          // ============================================================
          // EXPERIENCE
          // ============================================================
          _buildSectionLabel('Experience', isDark),
          const SizedBox(height: 8),

          _buildCard(isDark, [
            _buildSettingsTile(
              icon: Icons.menu_book_rounded,
              label: 'Borrowing Guide',
              isDark: isDark,
              trailing: _chevron(isDark),
              onTap: () => _showBorrowingGuide(isDark),
            ),

            _divider(isDark),

            _buildSettingsTile(
              icon: Icons.feedback_outlined,
              label: 'Send Feedback',
              isDark: isDark,
              trailing: _chevron(isDark),
              onTap: () => _showFeedbackDialog(isDark),
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

          // ============================================================
          // ABOUT
          // ============================================================
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
                    'By using this app you agree to borrow and purchase books responsibly, '
                    'return borrowed items on time, and keep your account information accurate. '
                    'Full terms will be published here once finalized.',
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
                    'We only collect the information needed to manage your account, '
                    'orders, and borrowed books. Your data is never sold to third parties. '
                    'Full policy will be published here once finalized.',
              ),
            ),
          ]),

          const SizedBox(height: 26),

          // ============================================================
          // LOGOUT
          // ============================================================
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

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  void _showDeleteAccountDialog(bool isDark) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: _deleteAccountBloc,
          child: BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
            listener: (blocContext, state) async {
              if (state is DeleteAccountSuccess) {
                final prefs = await SharedPreferences.getInstance();

                // Remove all authentication/user data.
                await prefs.remove('auth_token');
                await prefs.remove('token');
                await prefs.remove('user');
                await prefs.remove('user_data');
                await prefs.remove('fcm_token');

                phoneController.dispose();

                if (!mounted) return;

                // Close dialog.
                Navigator.of(dialogContext).pop();

                // Go to login and remove all previous routes.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SigninScreen()),
                  (route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your account has been permanently deleted.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }

              if (state is DeleteAccountFailure) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },

            builder: (blocContext, state) {
              final isLoading = state is DeleteAccountLoading;

              return AlertDialog(
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB33A3A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Color(0xFFB33A3A),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to permanently '
                      'delete your account?\n\n'
                      'Your account and its associated data '
                      'will be permanently deleted. '
                      'This action cannot be undone.',
                      style: TextStyle(
                        height: 1.5,
                        color: isDark
                            ? AppColors.textDark.withOpacity(0.7)
                            : AppColors.textLight.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Enter your phone number to confirm:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),

                actions: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            phoneController.dispose();
                            Navigator.of(dialogContext).pop();
                          },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB33A3A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: isLoading
                        ? null
                        : () {
                            final phone = phoneController.text.trim();

                            if (phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter your phone number',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            blocContext.read<DeleteAccountBloc>().add(
                              DeleteAccountRequested(phone: phone),
                            );
                          },

                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Delete Permanently'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: _logoutBloc,
          child: BlocConsumer<LogoutBloc, LogoutState>(
            listener: (blocContext, state) {
              if (state is LogoutSuccess) {
                Navigator.of(dialogContext).pop();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SigninScreen()),
                  (route) => false,
                );
              }

              if (state is LogoutFailure) {
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },

            builder: (blocContext, state) {
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
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB33A3A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: isLoading
                        ? null
                        : () {
                            blocContext.read<LogoutBloc>().add(
                              LogoutRequested(),
                            );
                          },

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
        );
      },
    );
  }

  // ============================================================
  // RATE APP
  // ============================================================

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
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
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
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: selectedStars == 0
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();

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

  // ============================================================
  // BORROWING GUIDE
  // ============================================================

  void _showBorrowingGuide(bool isDark) {
    _showTextSheet(
      isDark,
      title: 'Borrowing Guide',
      body:
          'How to borrow a book:\n\n'
          '1. Browse the available books in the library.\n\n'
          '2. Open the book details page to view its information and availability.\n\n'
          '3. Choose "Borrow" to request the book.\n\n'
          '4. Confirm your request and complete the checkout process.\n\n'
          '5. You can track your borrowing requests from Book Requests and your previous orders from Order History.\n\n'
          'If the book is currently unavailable, you can join the Waiting List and receive an update when it becomes available.',
    );
  }

  // ============================================================
  // SEND FEEDBACK
  // ============================================================

  void _showFeedbackDialog(bool isDark) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          title: Text(
            'Send Feedback',
            style: TextStyle(
              color: isDark ? AppColors.textDark : AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
            decoration: InputDecoration(
              hintText: 'Tell us what you think about the app...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.textDark.withOpacity(0.4)
                    : AppColors.textLight.withOpacity(0.4),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                final feedback = controller.text.trim();

                controller.dispose();

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Thank you! Your feedback has been received.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                debugPrint('User feedback: $feedback');
              },

              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // TEXT BOTTOM SHEET
  // ============================================================

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

      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,

          builder: (context, scrollController) {
            return Padding(
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
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================

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

  // ============================================================
  // CARD
  // ============================================================

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

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
    );
  }

  // ============================================================
  // CHEVRON
  // ============================================================

  Widget _chevron(bool isDark) {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 14,
      color: isDark
          ? AppColors.textDark.withOpacity(0.35)
          : AppColors.textLight.withOpacity(0.35),
    );
  }

  // ============================================================
  // SETTINGS TILE
  // ============================================================

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

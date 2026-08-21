import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/theme.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
          'Contact Us',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // HEADER
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accent.withOpacity(0.10)),
              ),

              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(17),
                    ),

                    child: Icon(
                      Icons.support_agent_rounded,
                      color: accent,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'We’re here to help',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Have a question or need assistance? '
                          'Feel free to reach out to us.',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Get in touch',
              style: TextStyle(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            // =====================================================
            // CONTACT METHODS
            // =====================================================
            _contactCard(
              context: context,
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'support@hibrwaraq.com',
              accent: accent,
              primaryText: primaryText,
              secondaryText: secondaryText,
              cardColor: cardColor,
              borderColor: borderColor,
            ),

            const SizedBox(height: 10),

            _contactCard(
              context: context,
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: '+963 11 000 0000',
              accent: accent,
              primaryText: primaryText,
              secondaryText: secondaryText,
              cardColor: cardColor,
              borderColor: borderColor,
            ),

            const SizedBox(height: 10),

            _contactCard(
              context: context,
              icon: Icons.location_on_outlined,
              title: 'Library Location',
              value: 'University Library',
              accent: accent,
              primaryText: primaryText,
              secondaryText: secondaryText,
              cardColor: cardColor,
              borderColor: borderColor,
            ),

            const SizedBox(height: 25),

            // =====================================================
            // MESSAGE
            // =====================================================
            Text(
              'Send us a message',
              style: TextStyle(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),

              child: Column(
                children: [
                  _inputField(
                    context,
                    hint: 'Your name',
                    icon: Icons.person_outline_rounded,
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 10),

                  _inputField(
                    context,
                    hint: 'Your email',
                    icon: Icons.email_outlined,
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 10),

                  _inputField(
                    context,
                    hint: 'Write your message...',
                    icon: Icons.message_outlined,
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    isDark: isDark,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Send message
                      },

                      icon: const Icon(Icons.send_rounded, size: 19),

                      label: const Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: accent.withOpacity(0.09),
              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(icon, color: accent, size: 21),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: secondaryText),
        ],
      ),
    );
  }

  Widget _inputField(
    BuildContext context, {
    required String hint,
    required IconData icon,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,

      style: TextStyle(color: primaryText),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: secondaryText, fontSize: 13),

        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 55 : 0),
          child: Icon(icon, color: accent, size: 20),
        ),

        filled: true,

        fillColor: isDark ? AppColors.inputDark : AppColors.inputLight,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.04),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: accent, width: 1.3),
        ),
      ),
    );
  }
}

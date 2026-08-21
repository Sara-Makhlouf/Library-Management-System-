import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestBloc.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestEvent.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestState.dart';

class BookRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const BookRequestDetailScreen({Key? key, required this.requestId})
    : super(key: key);

  @override
  State<BookRequestDetailScreen> createState() =>
      _BookRequestDetailScreenState();
}

class _BookRequestDetailScreenState extends State<BookRequestDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BookRequestBloc>().add(
        ShowBookRequestDetailEvent(id: widget.requestId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    final cardColor = isDark ? AppColors.darkCard : Colors.white;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final accent = AppColors.primary;

    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,

        iconTheme: IconThemeData(color: primaryText),

        title: Text(
          'Request Details',
          style: TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: BlocConsumer<BookRequestBloc, BookRequestState>(
        listener: (context, state) {
          if (state is BookRequestActionSuccessState) {
            if (!mounted) return;

            // Delay navigation until the current frame is finished.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              Navigator.of(context).pop();
            });
          }
        },

        builder: (context, state) {
          // ========================================================
          // LOADING
          // ========================================================

          if (state is BookRequestLoading) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          // ========================================================
          // DETAILS
          // ========================================================

          if (state is BookRequestDetailLoadedState) {
            final request = state.request;

            final status = request.status.toString().toLowerCase();

            final isPending = status == 'pending';
            final isApproved = status == 'approved' || status == 'accepted';

            final isRejected = status == 'rejected' || status == 'declined';

            final statusColor = isPending
                ? Colors.orange
                : isApproved
                ? Colors.green
                : isRejected
                ? Colors.redAccent
                : Colors.blue;

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // MAIN BOOK CARD
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.045),
                                  blurRadius: 20,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==========================================
                          // BOOK HEADER
                          // ==========================================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: accent,
                                  size: 31,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.bookTitle,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryText,
                                        fontSize: 19,
                                        height: 1.25,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),

                                    const SizedBox(height: 7),

                                    Text(
                                      'Requested Book',
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          Divider(height: 1, color: borderColor),

                          const SizedBox(height: 20),

                          // ==========================================
                          // AUTHOR
                          // ==========================================
                          _buildInfoCard(
                            icon: Icons.person_outline_rounded,
                            label: 'Author',
                            value: request.authorName,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            accent: accent,
                            cardColor: cardColor,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 12),

                          // ==========================================
                          // STATUS
                          // ==========================================
                          _buildInfoCard(
                            icon: Icons.radio_button_checked_rounded,
                            label: 'Status',
                            value: _formatStatus(request.status),
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            accent: statusColor,
                            cardColor: statusColor.withOpacity(0.06),
                            isDark: isDark,
                            valueColor: statusColor,
                          ),

                          const SizedBox(height: 12),

                          // ==========================================
                          // NOTES
                          // ==========================================
                          _buildInfoCard(
                            icon: Icons.notes_rounded,
                            label: 'Your Notes',
                            value: request.notes?.isNotEmpty == true
                                ? request.notes!
                                : 'No notes added',
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            accent: accent,
                            cardColor: cardColor,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 12),

                          // ==========================================
                          // ADMIN NOTE
                          // ==========================================
                          _buildInfoCard(
                            icon: Icons.admin_panel_settings_outlined,
                            label: 'Admin Note',
                            value: request.adminNote?.isNotEmpty == true
                                ? request.adminNote!
                                : 'No admin notes yet',
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            accent: accent,
                            cardColor: cardColor,
                            isDark: isDark,
                          ),

                          // ==========================================
                          // CREATED DATE
                          // ==========================================
                          if (request.createdAt != null &&
                              request.createdAt!.isNotEmpty) ...[
                            const SizedBox(height: 12),

                            _buildInfoCard(
                              icon: Icons.access_time_rounded,
                              label: 'Created At',
                              value: request.createdAt!,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              accent: accent,
                              cardColor: cardColor,
                              isDark: isDark,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // DELETE BUTTON
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDeleteConfirmation(context, request.id);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 21,
                        ),

                        label: const Text(
                          'Cancel Request',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // IMPORTANT:
                    // Extra space above the phone navigation buttons
                    // ==================================================
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 18,
                    ),
                  ],
                ),
              ),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (state is BookRequestErrorState) {
            return _buildErrorState(
              context,
              state.error,
              accent,
              primaryText,
              secondaryText,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ================================================================
  // INFO CARD
  // ================================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryText,
    required Color secondaryText,
    required Color accent,
    required Color cardColor,
    required bool isDark,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.025)
            : Colors.black.withOpacity(0.018),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? primaryText,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DELETE CONFIRMATION
  // ================================================================

  void _showDeleteConfirmation(BuildContext context, int requestId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: Text(
            'Cancel Request?',
            style: TextStyle(color: primaryText, fontWeight: FontWeight.w800),
          ),

          content: Text(
            'Are you sure you want to cancel this book request?',
            style: TextStyle(color: secondaryText, height: 1.5),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Keep Request',
                style: TextStyle(
                  color: secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                context.read<BookRequestBloc>().add(
                  CancelBookRequestEvent(id: requestId),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: const Text(
                'Cancel Request',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // ERROR STATE
  // ================================================================

  Widget _buildErrorState(
    BuildContext context,
    String error,
    Color accent,
    Color primaryText,
    Color secondaryText,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to Load Request',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryText, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                context.read<BookRequestBloc>().add(
                  ShowBookRequestDetailEvent(id: widget.requestId),
                );
              },

              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),

              icon: const Icon(Icons.refresh_rounded, size: 19),

              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FORMAT STATUS
  // ================================================================

  String _formatStatus(dynamic status) {
    final value = status.toString().trim();

    if (value.isEmpty) {
      return 'Unknown';
    }

    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                    '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

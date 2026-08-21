import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/core/theme.dart';

import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestBloc.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestEvent.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestState.dart';

import 'package:library_mobile_app/feature/BookRequest/presentation/BookRequestDetailScreen.dart';
import 'package:library_mobile_app/feature/BookRequest/presentation/widget/AddBookRequestBottomSheet.dart';

class BookRequestsScreen extends StatefulWidget {
  const BookRequestsScreen({Key? key}) : super(key: key);

  @override
  State<BookRequestsScreen> createState() => _BookRequestsScreenState();
}

class _BookRequestsScreenState extends State<BookRequestsScreen> {
  StreamSubscription<RemoteMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BookRequestBloc>().add(FetchBookRequestsEvent());
    });

    _listenForBookRequestUpdates();
  }

  // ============================================================
  // REAL-TIME FCM LISTENER
  // ============================================================

  void _listenForBookRequestUpdates() {
    _messageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      if (!mounted) return;

      final data = message.data;

      if (data.isEmpty) return;

      final type = data['type']?.toString();

      if (type != 'book_request_status_updated') {
        return;
      }

      final requestId = int.tryParse(data['request_id']?.toString() ?? '');

      final status = data['status']?.toString();

      final adminNote = data['admin_note']?.toString();

      if (requestId == null || status == null) {
        return;
      }

      _updateRequestLocally(
        requestId: requestId,
        status: status,
        adminNote: adminNote,
      );

      _showStatusUpdateSnackBar(status, adminNote);
    });
  }

  // ============================================================
  // UPDATE REQUEST WITHOUT API REFRESH
  // ============================================================

  void _updateRequestLocally({
    required int requestId,
    required String status,
    String? adminNote,
  }) {
    final bloc = context.read<BookRequestBloc>();

    final currentState = bloc.state;

    if (currentState is! BookRequestsLoadedState) {
      return;
    }

    final updatedRequests = currentState.requests.map((request) {
      if (request.id != requestId) {
        return request;
      }

      /*
       * إذا الـ request model عندك immutable
       * استخدم copyWith هنا.
       *
       * مثال:
       *
       * return request.copyWith(
       *   status: status,
       *   adminNote: adminNote,
       * );
       *
       * إذا ما عندك copyWith، لازم نضيفها للـ Model.
       */

      return request.copyWith(status: status, adminNote: adminNote);
    }).toList();

    bloc.emit(BookRequestsLoadedState(requests: updatedRequests));
  }

  // ============================================================
  // STATUS UPDATE SNACKBAR
  // ============================================================

  void _showStatusUpdateSnackBar(String status, String? adminNote) {
    if (!mounted) return;

    final normalizedStatus = status.toLowerCase();

    Color color;
    IconData icon;
    String message;

    switch (normalizedStatus) {
      case 'approved':
      case 'accepted':
        color = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        message = 'Your book request has been approved.';
        break;

      case 'rejected':
      case 'declined':
        color = Colors.redAccent;
        icon = Icons.cancel_outlined;
        message = 'Your book request has been rejected.';
        break;

      case 'pending':
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        message = 'Your book request is pending.';
        break;

      default:
        color = AppColors.primary;
        icon = Icons.info_outline_rounded;
        message = 'Your book request status has been updated.';
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

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

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryText),
        title: Text(
          'Book Requests',
          style: TextStyle(
            color: primaryText,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: BlocConsumer<BookRequestBloc, BookRequestState>(
        listenWhen: (previous, current) =>
            current is BookRequestActionSuccessState ||
            current is BookRequestErrorState,

        listener: (context, state) {
          if (!mounted) return;

          if (state is BookRequestActionSuccessState) {
            _showSnackBar(context, state.message, Colors.green);
          }

          if (state is BookRequestErrorState) {
            _showSnackBar(context, state.error, Colors.redAccent);
          }
        },

        buildWhen: (previous, current) =>
            current is BookRequestLoading ||
            current is BookRequestsLoadedState ||
            current is BookRequestErrorState,

        builder: (context, state) {
          // ====================================================
          // LOADING
          // ====================================================

          if (state is BookRequestLoading) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          // ====================================================
          // ERROR
          // ====================================================

          if (state is BookRequestErrorState) {
            return _buildErrorState(
              context,
              state.error,
              accent,
              primaryText,
              secondaryText,
            );
          }

          // ====================================================
          // LOADED
          // ====================================================

          if (state is BookRequestsLoadedState) {
            if (state.requests.isEmpty) {
              return _buildEmptyState(
                context,
                accent,
                primaryText,
                secondaryText,
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),

              itemCount: state.requests.length,

              itemBuilder: (context, index) {
                final request = state.requests[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRequestCard(
                    context: context,
                    request: request,
                    isDark: isDark,
                    cardColor: cardColor,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    accent: accent,
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),

      // ========================================================
      // ADD REQUEST BUTTON
      // ========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openAddRequestSheet(context);
        },

        backgroundColor: accent,

        foregroundColor: isDark ? AppColors.backgroundDark : Colors.white,

        elevation: 5,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),

        icon: const Icon(Icons.add_rounded, size: 21),

        label: const Text(
          'Request a New Book',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // =============================================================
  // REQUEST CARD
  // =============================================================

  Widget _buildRequestCard({
    required BuildContext context,
    required dynamic request,
    required bool isDark,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accent,
  }) {
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

    final statusBackground = statusColor.withOpacity(0.10);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),

        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),

        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final bookRequestBloc = context.read<BookRequestBloc>();

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bookRequestBloc,
                  child: BookRequestDetailScreen(requestId: request.id),
                ),
              ),
            );

            if (!mounted) return;

            bookRequestBloc.add(FetchBookRequestsEvent());
          },
          child: Padding(
            padding: const EdgeInsets.all(13),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                // =================================================
                // BOOK ICON
                // =================================================
                Container(
                  width: 62,
                  height: 62,

                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(17),
                  ),

                  child: Icon(Icons.menu_book_rounded, color: accent, size: 28),
                ),

                const SizedBox(width: 13),

                // =================================================
                // INFORMATION
                // =================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // BOOK TITLE
                      Text(
                        request.bookTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // AUTHOR
                      Text(
                        'Author: ${request.authorName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // STATUS
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(9),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Container(
                              width: 6,
                              height: 6,

                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 6),

                            Text(
                              _formatStatus(request.status),

                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // EMPTY STATE
  // =============================================================

  Widget _buildEmptyState(
    BuildContext context,
    Color accent,
    Color primaryText,
    Color secondaryText,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: accent.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'No Book Requests Yet',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Request a book that is not currently available in the library.',
              textAlign: TextAlign.center,

              style: TextStyle(color: secondaryText, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: () {
                _openAddRequestSheet(context);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              icon: const Icon(Icons.add_rounded, size: 19),

              label: const Text(
                'Request a Book',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // ERROR STATE
  // =============================================================

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
              width: 82,
              height: 82,

              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to Load Requests',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: primaryText,
                fontSize: 17,
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
                if (!mounted) return;

                context.read<BookRequestBloc>().add(FetchBookRequestsEvent());
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

  // =============================================================
  // ADD REQUEST SHEET
  // =============================================================

  void _openAddRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) {
        return BlocProvider.value(
          value: context.read<BookRequestBloc>(),
          child: const AddBookRequestBottomSheet(),
        );
      },
    );
  }

  // =============================================================
  // STATUS FORMAT
  // =============================================================

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

  // =============================================================
  // SNACKBAR
  // =============================================================

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == Colors.green
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          backgroundColor: color,

          behavior: SnackBarBehavior.floating,

          margin: const EdgeInsets.all(16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}

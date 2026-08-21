import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Bloc/WaitingListBloc.dart';
import 'package:library_mobile_app/feature/books/waiting_list/data/WaitingListItemodel.dart';
import 'package:library_mobile_app/feature/books/waiting_list/event/WaitingListEvent.dart';
import 'package:library_mobile_app/feature/books/waiting_list/state/WaitingListState.dart';

class MyWaitingListScreen extends StatefulWidget {
  const MyWaitingListScreen({super.key});

  @override
  State<MyWaitingListScreen> createState() => _MyWaitingListScreenState();
}

class _MyWaitingListScreenState extends State<MyWaitingListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WaitingListBloc>().add(GetMyWaitingListEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final accent = AppColors.primary;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Waiting List',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: BlocConsumer<WaitingListBloc, WaitingListState>(
        listener: (context, state) {
          if (state is WaitingListActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF22C55E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            context.read<WaitingListBloc>().add(GetMyWaitingListEvent());
          } else if (state is WaitingListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WaitingListLoading) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          if (state is WaitingListError) {
            return _buildErrorState(state.message, secondaryText, accent);
          }

          if (state is MyWaitingListLoaded) {
            final List rawData = state.data['data'] ?? [];
            final items = rawData
                .map((e) => WaitingListItem.fromJson(e))
                .toList();

            if (items.isEmpty) {
              return _buildEmptyState(secondaryText, accent);
            }

            return RefreshIndicator(
              color: accent,
              onRefresh: () async {
                context.read<WaitingListBloc>().add(GetMyWaitingListEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildItemCard(
                    context,
                    item,
                    cardColor,
                    borderColor,
                    primaryText,
                    secondaryText,
                    accent,
                    isDark,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WaitingListItem item,
    Color cardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
    Color accent,
    bool isDark,
  ) {
    final isAvailable = item.book.stock > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                (item.book.cover != null && item.book.cover!.startsWith('http'))
                ? Image.network(
                    item.book.cover!,
                    width: 64,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _coverPlaceholder(accent),
                  )
                : _coverPlaceholder(accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAvailable
                            ? Icons.check_circle_outline
                            : Icons.hourglass_empty_rounded,
                        size: 14,
                        color: isAvailable ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAvailable ? 'Available Now' : 'Still Unavailable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<WaitingListBloc>().add(
                        LeaveWaitingListEvent(item.bookId),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text(
                      'Leave Waiting List',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color secondaryText, Color accent) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.hourglass_empty_rounded,
          size: 80,
          color: accent.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No waiting list requests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Books you add to waiting list will appear here',
            style: TextStyle(
              fontSize: 13,
              color: secondaryText.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, Color secondaryText, Color accent) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.wifi_off_rounded, size: 60, color: accent.withOpacity(0.3)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            message,
            style: TextStyle(color: secondaryText),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder(Color accent) {
    return Container(
      width: 64,
      height: 90,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.book_outlined, color: accent, size: 28),
    );
  }
}

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
    BlocProvider.of<BookRequestBloc>(
      context,
    ).add(ShowBookRequestDetailEvent(id: widget.requestId));
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
          'Book Request Details',
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
      body: BlocConsumer<BookRequestBloc, BookRequestState>(
        listener: (context, state) {
          if (state is BookRequestActionSuccessState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is BookRequestLoading) {
            return Center(child: CircularProgressIndicator(color: accent));
          } else if (state is BookRequestDetailLoadedState) {
            final req = state.request;
            final isPending = req.status == 'pending';
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.menu_book_outlined,
                                color: accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                req.bookTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 16),
                        _detailRow(
                          Icons.person_outline,
                          'اسم المؤلف',
                          req.authorName,
                          primaryText,
                          secondaryText,
                          accent,
                        ),
                        const SizedBox(height: 12),
                        _detailRow(
                          Icons.info_outline,
                          'الحالة',
                          req.status,
                          primaryText,
                          secondaryText,
                          accent,
                          statusColor: isPending
                              ? Colors.orange
                              : const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 12),
                        _detailRow(
                          Icons.notes_outlined,
                          'الملاحظات',
                          req.notes ?? "لا توجد ملاحظات",
                          primaryText,
                          secondaryText,
                          accent,
                        ),
                        const SizedBox(height: 12),
                        _detailRow(
                          Icons.admin_panel_settings_outlined,
                          'ملاحظات المشرف',
                          req.adminNote ?? "لا توجد ملاحظات إدارية بعد",
                          primaryText,
                          secondaryText,
                          accent,
                        ),
                        if (req.createdAt != null &&
                            req.createdAt!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _detailRow(
                            Icons.access_time_outlined,
                            'تاريخ الإنشاء',
                            req.createdAt!,
                            primaryText,
                            secondaryText,
                            accent,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        BlocProvider.of<BookRequestBloc>(
                          context,
                        ).add(CancelBookRequestEvent(id: req.id));
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'إلغاء / حذف الطلب',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else if (state is BookRequestErrorState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'خطأ: ${state.error}',
                    style: TextStyle(color: secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color primaryText,
    Color secondaryText,
    Color accent, {
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: statusColor ?? primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

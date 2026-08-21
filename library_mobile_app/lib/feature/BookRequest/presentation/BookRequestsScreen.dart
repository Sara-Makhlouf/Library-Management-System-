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
  @override
  void initState() {
    super.initState();
    context.read<BookRequestBloc>().add(FetchBookRequestsEvent());
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Book Requests',
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF22C55E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is BookRequestErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is BookRequestLoading ||
            current is BookRequestsLoadedState ||
            current is BookRequestErrorState,
        builder: (context, state) {
          if (state is BookRequestLoading) {
            return Center(child: CircularProgressIndicator(color: accent));
          } else if (state is BookRequestsLoadedState) {
            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 80,
                      color: accent.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No previous requests',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اضغط على + لطلب كتاب جديد',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryText.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                final isPending = request.status == 'pending';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.05),
                    ),
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
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<BookRequestBloc>(context),
                              child: BookRequestDetailScreen(
                                requestId: request.id,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.bookTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: primaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'المؤلف: ${request.authorName}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: secondaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? Colors.orange.withOpacity(0.12)
                                          : const Color(
                                              0xFF2563EB,
                                            ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      request.status,
                                      style: TextStyle(
                                        color: isPending
                                            ? Colors.orange
                                            : const Color(0xFF2563EB),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: secondaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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
                    'حدث خطأ: ${state.error}',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<BookRequestBloc>(context),
              child: const AddBookRequestBottomSheet(),
            ),
          );
        },
        backgroundColor: accent,
        foregroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: const Text(
          'Request a new book',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

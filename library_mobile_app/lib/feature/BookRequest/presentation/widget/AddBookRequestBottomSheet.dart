import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestBloc.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestEvent.dart';

class AddBookRequestBottomSheet extends StatefulWidget {
  const AddBookRequestBottomSheet({super.key});

  @override
  State<AddBookRequestBottomSheet> createState() =>
      _AddBookRequestBottomSheetState();
}

class _AddBookRequestBottomSheetState extends State<AddBookRequestBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.darkCard : Colors.white;

    final primaryText = isDark ? AppColors.textDark : AppColors.textLight;

    final secondaryText = isDark ? Colors.white54 : AppColors.textGrey;

    final accent = AppColors.primary;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: keyboardHeight > 0 ? keyboardHeight + 12 : 20,
        top: 20,
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Header
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: accent,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request a Book',
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Can’t find a book? Let us know.',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close button
                        Material(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context),
                            child: const SizedBox(
                              width: 38,
                              height: 38,
                              child: Icon(Icons.close_rounded, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // Book title
                    _buildLabel('Book Title', primaryText),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: primaryText),
                      decoration: _inputDecoration(
                        hint: 'Enter the book title',
                        icon: Icons.book_outlined,
                        accent: accent,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the book title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Author
                    _buildLabel('Author', primaryText),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _authorController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: primaryText),
                      decoration: _inputDecoration(
                        hint: 'Enter the author name',
                        icon: Icons.person_outline_rounded,
                        accent: accent,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the author name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Notes
                    _buildLabel('Notes', primaryText, optional: true),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _notesController,
                      textInputAction: TextInputAction.newline,
                      maxLines: 3,
                      style: TextStyle(color: primaryText),
                      decoration: _inputDecoration(
                        hint: 'Add any additional information...',
                        icon: Icons.notes_outlined,
                        accent: accent,
                        isDark: isDark,
                        alignIconTop: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: accent.withOpacity(0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send_rounded, size: 19),
                            SizedBox(width: 9),
                            Text(
                              'Submit Request',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Cancel
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: secondaryText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<BookRequestBloc>().add(
      SubmitBookRequestEvent(
        bookTitle: _titleController.text.trim(),
        authorName: _authorController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );

    Navigator.pop(context);
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text, Color color, {bool optional = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 5),
          Text(
            '(Optional)',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color accent,
    required bool isDark,
    bool alignIconTop = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : AppColors.textGrey.withOpacity(0.7),
        fontSize: 13,
      ),

      prefixIcon: Padding(
        padding: alignIconTop
            ? const EdgeInsets.only(bottom: 38)
            : EdgeInsets.zero,
        child: Icon(icon, color: accent.withOpacity(0.75), size: 20),
      ),

      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.035)
          : Colors.black.withOpacity(0.025),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.06),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.06),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent, width: 1.4),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }
}

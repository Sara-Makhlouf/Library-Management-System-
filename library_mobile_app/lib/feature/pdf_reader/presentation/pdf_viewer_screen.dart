import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../bloc/read_book_cubit.dart';
import '../data/repo/pdf_book_repo.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReadBookCubit(context.read<PdfBookRepository>())
            ..fetchAndOpenBook(bookId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Book Reader')),
        body: BlocBuilder<ReadBookCubit, ReadBookState>(
          builder: (context, state) {
            if (state is ReadBookLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Downloading...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            if (state is ReadBookError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              );
            }

            if (state is ReadBookSuccess) {
              return SfPdfViewer.file(state.file);
            }

            return const Center(child: Text('Preparing book...'));
          },
        ),
      ),
    );
  }
}

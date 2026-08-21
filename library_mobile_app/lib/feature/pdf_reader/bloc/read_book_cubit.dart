import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repo/pdf_book_repo.dart';

abstract class ReadBookState {}

class ReadBookInitial extends ReadBookState {}

class ReadBookLoading extends ReadBookState {}

class ReadBookSuccess extends ReadBookState {
  ReadBookSuccess(this.file);

  final File file;
}

class ReadBookError extends ReadBookState {
  ReadBookError(this.message);

  final String message;
}

class ReadBookCubit extends Cubit<ReadBookState> {
  ReadBookCubit(this._repository) : super(ReadBookInitial());

  final PdfBookRepository _repository;

  Future<void> fetchAndOpenBook(int bookId) async {
    emit(ReadBookLoading());

    try {
      final file = await _repository.downloadAndGetBookPdf(bookId);
      emit(ReadBookSuccess(file));
    } on PdfBookException catch (e) {
      emit(ReadBookError(e.message));
    } catch (_) {
      emit(ReadBookError('Unable to open this book right now.'));
    }
  }
}

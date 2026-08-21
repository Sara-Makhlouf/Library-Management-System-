import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestEvent.dart';
import 'package:library_mobile_app/feature/BookRequest/bloc/BookRequestState.dart';
import 'package:library_mobile_app/feature/BookRequest/data/BookRequestRepository.dart';

class BookRequestBloc extends Bloc<BookRequestEvent, BookRequestState> {
  final BookRequestRepository repository;

  BookRequestBloc({required this.repository}) : super(BookRequestInitial()) {
    on<FetchBookRequestsEvent>(_onFetchBookRequests);
    on<SubmitBookRequestEvent>(_onSubmitBookRequest);
    on<ShowBookRequestDetailEvent>(_onShowBookRequestDetail);
    on<CancelBookRequestEvent>(_onCancelBookRequest);
  }

  Future<void> _onFetchBookRequests(
    FetchBookRequestsEvent event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(BookRequestLoading());
    try {
      final requests = await repository.getMyBookRequests();
      emit(BookRequestsLoadedState(requests: requests));
    } catch (e) {
      emit(BookRequestErrorState(error: e.toString()));
    }
  }

  Future<void> _onSubmitBookRequest(
    SubmitBookRequestEvent event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(BookRequestLoading());
    try {
      await repository.submitBookRequest(
        bookTitle: event.bookTitle,
        authorName: event.authorName,
        notes: event.notes,
      );
      emit(
        BookRequestActionSuccessState(
          message: 'تم استلام طلبك بنجاح، سنحاول توفير الكتاب قريباً',
        ),
      );

      add(FetchBookRequestsEvent());
    } catch (e) {
      emit(BookRequestErrorState(error: e.toString()));
    }
  }

  Future<void> _onShowBookRequestDetail(
    ShowBookRequestDetailEvent event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(BookRequestLoading());
    try {
      final request = await repository.showBookRequest(event.id);
      emit(BookRequestDetailLoadedState(request: request));
    } catch (e) {
      emit(BookRequestErrorState(error: e.toString()));
    }
  }

  Future<void> _onCancelBookRequest(
    CancelBookRequestEvent event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(BookRequestLoading());
    try {
      await repository.cancelBookRequest(event.id);
      emit(BookRequestActionSuccessState(message: 'تم إلغاء طلب الكتاب بنجاح'));

      add(FetchBookRequestsEvent());
    } catch (e) {
      emit(BookRequestErrorState(error: e.toString()));
    }
  }
}

import 'package:library_mobile_app/feature/BookRequest/data/BookRequestModel.dart';

abstract class BookRequestState {}

class BookRequestInitial extends BookRequestState {}

class BookRequestLoading extends BookRequestState {}

class BookRequestsLoadedState extends BookRequestState {
  final List<BookRequestModel> requests;
  BookRequestsLoadedState({required this.requests});
}

class BookRequestDetailLoadedState extends BookRequestState {
  final BookRequestModel request;
  BookRequestDetailLoadedState({required this.request});
}

class BookRequestActionSuccessState extends BookRequestState {
  final String message;
  BookRequestActionSuccessState({required this.message});
}

class BookRequestErrorState extends BookRequestState {
  final String error;
  BookRequestErrorState({required this.error});
}

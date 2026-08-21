// library_mobile_app/feature/homepage/bloc/home_event.dart

part of 'home_bloc.dart';

abstract class HomeEvent {}

class GetPopularBooksEvent extends HomeEvent {}

class GetOffersEvent extends HomeEvent {}

class ChangeTabEvent extends HomeEvent {
  final int index;
  ChangeTabEvent(this.index);
}

class SearchBooksEvent extends HomeEvent {
  final String query;
  SearchBooksEvent(this.query);
}

class FetchBooksByCategoryEvent extends HomeEvent {
  final int categoryId;
  FetchBooksByCategoryEvent({required this.categoryId});
}

class FetchCategoriesEvent extends HomeEvent {}

class FetchHomeBooksEvent extends HomeEvent {
  final int? categoryId;
  FetchHomeBooksEvent({this.categoryId});
}

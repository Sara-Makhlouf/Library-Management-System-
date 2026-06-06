part of 'home_bloc.dart';

abstract class HomeEvent {}

class GetPopularBooksEvent extends HomeEvent {}

class GetOffersEvent extends HomeEvent {}

class ChangeTabEvent extends HomeEvent {
  final int index;
  ChangeTabEvent(this.index);
}

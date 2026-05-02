part of 'home_bloc.dart';

abstract class HomeEvent {}

class GetPopularBooksEvent extends HomeEvent {}

// ✅ حدث جلب العروض الجديد
class GetOffersEvent extends HomeEvent {}

class ChangeTabEvent extends HomeEvent {
  final int index;
  ChangeTabEvent(this.index);
}
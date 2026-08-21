abstract class WaitingListState {}

class WaitingListInitial extends WaitingListState {}

class WaitingListLoading extends WaitingListState {}

class WaitingListActionSuccess extends WaitingListState {
  final String message;
  WaitingListActionSuccess(this.message);
}

class MyWaitingListLoaded extends WaitingListState {
  final dynamic data;
  MyWaitingListLoaded(this.data);
}

class WaitingListError extends WaitingListState {
  final String message;
  WaitingListError(this.message);
}

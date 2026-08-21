abstract class WaitingListEvent {}

class JoinWaitingListEvent extends WaitingListEvent {
  final int bookId;
  JoinWaitingListEvent(this.bookId);
}

class LeaveWaitingListEvent extends WaitingListEvent {
  final int bookId;
  LeaveWaitingListEvent(this.bookId);
}

class GetMyWaitingListEvent extends WaitingListEvent {}

abstract class BillsEvent {}

class FetchAllBillsEvent extends BillsEvent {}

class FetchBillDetailsEvent extends BillsEvent {
  final int billId;
  FetchBillDetailsEvent(this.billId);
}

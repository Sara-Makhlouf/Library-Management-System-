import 'package:library_mobile_app/feature/Bill/data/BillModel.dart';

abstract class BillsState {}

class BillsInitial extends BillsState {}

class BillsLoading extends BillsState {}

class AllBillsLoaded extends BillsState {
  final List<BillModel> bills;
  AllBillsLoaded(this.bills);
}

class BillDetailsLoaded extends BillsState {
  final BillModel bill;
  BillDetailsLoaded(this.bill);
}

class BillsError extends BillsState {
  final String error;
  BillsError(this.error);
}

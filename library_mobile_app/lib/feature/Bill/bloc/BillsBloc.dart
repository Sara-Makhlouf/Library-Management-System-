import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsEvent.dart';
import 'package:library_mobile_app/feature/Bill/bloc/BillsState.dart';
import 'package:library_mobile_app/feature/Bill/data/BillsRepository.dart';

class BillsBloc extends Bloc<BillsEvent, BillsState> {
  final BillsRepository billsRepository;

  BillsBloc({required this.billsRepository}) : super(BillsInitial()) {
    on<FetchAllBillsEvent>((event, emit) async {
      emit(BillsLoading());
      try {
        final bills = await billsRepository.getAllBills();
        emit(AllBillsLoaded(bills));
      } catch (e) {
        emit(BillsError(e.toString()));
      }
    });

    on<FetchBillDetailsEvent>((event, emit) async {
      emit(BillsLoading());
      try {
        final bill = await billsRepository.getBillDetails(event.billId);
        emit(BillDetailsLoaded(bill));
      } catch (e) {
        emit(BillsError(e.toString()));
      }
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/History/data/HistoryModel.dart';
import 'package:library_mobile_app/feature/History/data/HistoryRepository.dart';

abstract class HistoryEvent {}

class FetchHistoryEvent extends HistoryEvent {}

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<HistoryModel> orders;
  HistoryLoaded(this.orders);
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository repository;
  HistoryBloc(this.repository) : super(HistoryInitial()) {
    on<FetchHistoryEvent>((event, emit) async {
      emit(HistoryLoading());
      try {
        final orders = await repository.getOrderHistory();
        emit(HistoryLoaded(orders));
      } catch (e) {
        emit(HistoryError(e.toString()));
      }
    });
  }
}

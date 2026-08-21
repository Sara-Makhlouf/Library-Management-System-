import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/books/waiting_list/Repository/WaitingListRepository.dart';
import 'package:library_mobile_app/feature/books/waiting_list/event/WaitingListEvent.dart';
import 'package:library_mobile_app/feature/books/waiting_list/state/WaitingListState.dart';

class WaitingListBloc extends Bloc<WaitingListEvent, WaitingListState> {
  final WaitingListRepository repository;

  WaitingListBloc(this.repository) : super(WaitingListInitial()) {
    // التعامل مع حدث الانضمام لقائمة الانتظار
    on<JoinWaitingListEvent>((event, emit) async {
      emit(WaitingListLoading());
      try {
        final response = await repository.joinWaitingList(event.bookId);
        emit(
          WaitingListActionSuccess(
            response.data['message'] ?? 'تم إرسال الطلب بنجاح',
          ),
        );
      } catch (e) {
        emit(WaitingListError(e.toString()));
      }
    });

    // التعامل مع حدث حذف الطلب / الخروج من قائمة الانتظار
    on<LeaveWaitingListEvent>((event, emit) async {
      emit(WaitingListLoading());
      try {
        final response = await repository.leaveWaitingList(event.bookId);
        emit(
          WaitingListActionSuccess(
            response.data['message'] ?? 'تم إلغاء الطلب بنجاح',
          ),
        );
      } catch (e) {
        emit(WaitingListError(e.toString()));
      }
    });

    // التعامل مع حدث عرض قائمة طلبات الانتظار الخاصة بالزبون
    on<GetMyWaitingListEvent>((event, emit) async {
      emit(WaitingListLoading());
      try {
        final response = await repository.getMyWaitingList();
        emit(MyWaitingListLoaded(response.data));
      } catch (e) {
        emit(WaitingListError(e.toString()));
      }
    });
  }
}

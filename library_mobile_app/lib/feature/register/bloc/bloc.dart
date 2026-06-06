import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:library_mobile_app/feature/register/bloc/event.dart';
import 'package:library_mobile_app/feature/register/bloc/state.dart';
import 'package:library_mobile_app/feature/register/data/repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<RegisterSubmittedEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        // دمج الاسم الأول والأخير لإرساله كـ name متوافق مع الباكيند
        final fullName = '${event.firstName} ${event.lastName}'.trim();

        final result = await authRepository.registerUser(
          name: fullName,
          phone: event.phone,
          password: event.password,
          passwordConfirmation: event.passwordConfirmation,
          avatarFile: event.avatar,
        );

        emit(AuthSuccess(result));
      } catch (e) {
        emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

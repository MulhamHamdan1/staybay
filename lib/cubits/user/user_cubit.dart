import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/user/user_state.dart';
import 'package:staybay/services/get_me_service.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  Future<void> getMe() async {
    emit(UserLoading());
    try {
      final user = await GetMeService.getMe();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError("Unauthenticated please try logout and login again"));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void logout() {
    emit(UserInitial());
  }
}

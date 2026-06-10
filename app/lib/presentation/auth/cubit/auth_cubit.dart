import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/screen_state.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthCubit extends Cubit<ScreenState<List<UserModel>>> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(const ScreenState());

  Future<void> loadUsers() async {
    emit(const ScreenState(status: ScreenStatus.loading));
    try {
      final users = await _repo.getUsers();
      emit(ScreenState(status: ScreenStatus.success, data: users));
    } catch (e) {
      emit(ScreenState(status: ScreenStatus.failure, errorMessage: e.toString()));
    }
  }
}

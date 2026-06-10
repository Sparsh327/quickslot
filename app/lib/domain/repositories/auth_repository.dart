import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<List<UserModel>> getUsers();
}

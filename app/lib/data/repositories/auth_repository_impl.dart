import '../../domain/repositories/auth_repository.dart';
import '../data_sources/remote/api_client.dart';
import '../models/user_model.dart';
import '../../values/network_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _api;
  const AuthRepositoryImpl(this._api);

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await _api.get(NetworkConstants.users);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

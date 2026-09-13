import 'user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String username, required String password});
  Future<UserEntity> register({required String username, required String email, required String password});
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<bool> isAuthenticated();
}

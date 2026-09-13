import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final LocalStorageService storage;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.storage,
  });

  @override
  Future<UserEntity> login({required String username, required String password}) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 60,
        },
      );

      final userModel = UserModel.fromJson(response.data as Map<String, dynamic>);
      final token = userModel.token ?? response.data['accessToken'] as String?;
      final refreshToken = response.data['refreshToken'] as String?;

      if (token != null) {
        await storage.saveTokens(token: token, refreshToken: refreshToken);
      }

      await storage.saveUserJson(userModel.toJson());
      return userModel;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw const UnauthorizedException('Nom d utilisateur ou mot de passe incorrect.');
      }
      throw NetworkException(e.message ?? 'Erreur de connexion au service d authentification.');
    }
  }

  @override
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/users/add',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      final userModel = UserModel.fromJson(response.data as Map<String, dynamic>);
      return userModel;
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Impossible de creer le compte.');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // 1. Verifie le cache local
    final cached = storage.getUserJson();
    if (cached != null) {
      return UserModel.fromJson(cached);
    }

    // 2. Si un token existe, appel a /auth/me
    final token = await storage.getToken();
    if (token == null) return null;

    try {
      final response = await apiClient.dio.get('/auth/me');
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await storage.saveUserJson(user.toJson());
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await storage.clearTokens();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storage.getToken();
    return token != null && token.isNotEmpty;
  }
}

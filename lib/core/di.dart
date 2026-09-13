import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/api_client.dart';
import 'storage/local_storage.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/posts/data/post_repository_impl.dart';
import '../features/posts/domain/post_repository.dart';
import '../features/todos/data/todo_repository_impl.dart';
import '../features/todos/domain/todo_repository.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main()');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ApiClient(storage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(localStorageProvider);
  return AuthRepositoryImpl(apiClient: apiClient, storage: storage);
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(localStorageProvider);
  return PostRepositoryImpl(apiClient: apiClient, storage: storage);
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(localStorageProvider);
  return TodoRepositoryImpl(apiClient: apiClient, storage: storage);
});

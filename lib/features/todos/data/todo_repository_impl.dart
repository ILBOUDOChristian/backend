import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/todo_entity.dart';
import '../domain/todo_repository.dart';
import 'todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final ApiClient apiClient;
  final LocalStorageService storage;

  TodoRepositoryImpl({
    required this.apiClient,
    required this.storage,
  });

  @override
  Future<List<TodoEntity>> getTodos() async {
    try {
      final response = await apiClient.dio.get('/todos?limit=30');
      final List<dynamic> raw =
          response.data['todos'] as List<dynamic>? ?? [];
      final todos =
          raw.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();

      // Mise en cache Hive
      await storage.cacheTodos(todos.map((t) => t.toJson()).toList());

      return todos;
    } on DioException catch (e) {
      // Fallback cache hors-ligne
      final cached = storage.getCachedTodos();
      if (cached.isNotEmpty) {
        return cached.map((m) => TodoModel.fromJson(m)).toList();
      }
      if (e.error is ApiException) throw e.error as ApiException;
      throw NetworkException(
          e.message ?? 'Impossible de charger les todos.');
    }
  }

  @override
  Future<TodoEntity> toggleTodo(int id, bool completed) async {
    try {
      final response = await apiClient.dio.put(
        '/todos/$id',
        data: {'completed': completed},
      );
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw NetworkException(e.message ?? 'Impossible de modifier le todo.');
    }
  }
}

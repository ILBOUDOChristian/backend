import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di.dart';
import '../domain/todo_entity.dart';

class TodosState {
  final List<TodoEntity> todos;
  final bool isLoading;
  final bool isOffline;
  final String? errorMessage;

  const TodosState({
    this.todos = const [],
    this.isLoading = false,
    this.isOffline = false,
    this.errorMessage,
  });

  int get completed => todos.where((t) => t.completed).length;
  int get pending => todos.where((t) => !t.completed).length;

  TodosState copyWith({
    List<TodoEntity>? todos,
    bool? isLoading,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TodosNotifier extends StateNotifier<TodosState> {
  final Ref ref;

  TodosNotifier(this.ref) : super(const TodosState()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final todos = await ref.read(todoRepositoryProvider).getTodos();
      state = state.copyWith(todos: todos, isLoading: false, isOffline: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleTodo(int id, bool completed) async {
    // Optimistic update
    final updated = state.todos.map((t) {
      if (t.id == id) {
        return TodoEntity(
          id: t.id,
          todo: t.todo,
          completed: completed,
          userId: t.userId,
        );
      }
      return t;
    }).toList();
    state = state.copyWith(todos: updated);

    try {
      await ref.read(todoRepositoryProvider).toggleTodo(id, completed);
    } catch (_) {
      // Rollback
      final rolledBack = state.todos.map((t) {
        if (t.id == id) {
          return TodoEntity(
            id: t.id,
            todo: t.todo,
            completed: !completed,
            userId: t.userId,
          );
        }
        return t;
      }).toList();
      state = state.copyWith(todos: rolledBack);
    }
  }
}

final todosNotifierProvider =
    StateNotifierProvider<TodosNotifier, TodosState>((ref) {
  return TodosNotifier(ref);
});

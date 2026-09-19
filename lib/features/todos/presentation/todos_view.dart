import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todos_controller.dart';

class TodosScreen extends ConsumerWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todosNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taches (Todos REST)', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: state.todos.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  child: Row(
                    children: [
                      _StatChip(label: 'Total', value: state.todos.length, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      _StatChip(label: 'Faites', value: state.completed, color: Colors.green),
                      const SizedBox(width: 8),
                      _StatChip(label: 'En attente', value: state.pending, color: Colors.orange),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.todos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.todos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Erreur reseau', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(state.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(todosNotifierProvider.notifier).loadTodos(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            if (state.isOffline)
              Container(
                width: double.infinity,
                color: Colors.amber.shade800,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Mode Hors-Ligne � cache Hive',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(todosNotifierProvider.notifier).loadTodos(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: state.todos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: todo.completed
                              ? Colors.green.shade200
                              : Colors.grey.shade300,
                        ),
                      ),
                      color: todo.completed ? Colors.green.shade50 : null,
                      child: CheckboxListTile(
                        value: todo.completed,
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(todosNotifierProvider.notifier)
                                .toggleTodo(todo.id, val);
                          }
                        },
                        title: Text(
                          todo.todo,
                          style: TextStyle(
                            decoration: todo.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.completed ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text('Utilisateur #${todo.userId} � ID: ${todo.id}',
                            style: const TextStyle(fontSize: 12)),
                        activeColor: Colors.green,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$label: $value',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:connected_app/features/todos/data/todo_model.dart';

void main() {
  group('TodoModel', () {
    test('fromJson parse correctement un todo valide', () {
      final json = {
        'id': 1,
        'todo': 'Apprendre Flutter et Riverpod',
        'completed': false,
        'userId': 3,
      };

      final todo = TodoModel.fromJson(json);

      expect(todo.id, equals(1));
      expect(todo.todo, equals('Apprendre Flutter et Riverpod'));
      expect(todo.completed, isFalse);
      expect(todo.userId, equals(3));
    });

    test('fromJson parse un todo marque comme complete', () {
      final json = {
        'id': 2,
        'todo': 'Tache deja effectuee',
        'completed': true,
        'userId': 1,
      };

      final todo = TodoModel.fromJson(json);

      expect(todo.completed, isTrue);
    });

    test('fromJson gere les valeurs manquantes avec defaults', () {
      final json = <String, dynamic>{};
      final todo = TodoModel.fromJson(json);

      expect(todo.id, equals(0));
      expect(todo.todo, equals(''));
      expect(todo.completed, isFalse);
      expect(todo.userId, equals(0));
    });

    test('toJson serialise correctement le todo', () {
      const todo = TodoModel(
        id: 5,
        todo: 'Ecrire des tests unitaires',
        completed: true,
        userId: 10,
      );

      final json = todo.toJson();

      expect(json['id'], equals(5));
      expect(json['todo'], equals('Ecrire des tests unitaires'));
      expect(json['completed'], isTrue);
      expect(json['userId'], equals(10));
    });

    test('roundtrip fromJson -> toJson -> fromJson conserve les donnees', () {
      final original = TodoModel.fromJson({
        'id': 42,
        'todo': 'Test de serialisation roundtrip',
        'completed': false,
        'userId': 7,
      });

      final json = original.toJson();
      final restored = TodoModel.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.todo, equals(original.todo));
      expect(restored.completed, equals(original.completed));
      expect(restored.userId, equals(original.userId));
    });
  });
}

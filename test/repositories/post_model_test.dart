import 'package:flutter_test/flutter_test.dart';
import 'package:connected_app/features/posts/data/post_model.dart';

void main() {
  group('PostModel', () {
    test('fromJson parse correctement un post valide', () {
      final json = {
        'id': 1,
        'title': 'Mon titre de test',
        'body': 'Contenu du post de test',
        'tags': ['flutter', 'dart', 'riverpod'],
        'reactions': {'likes': 42, 'dislikes': 3},
        'views': 150,
        'userId': 5,
      };

      final post = PostModel.fromJson(json);

      expect(post.id, equals(1));
      expect(post.title, equals('Mon titre de test'));
      expect(post.body, equals('Contenu du post de test'));
      expect(post.tags, containsAll(['flutter', 'dart', 'riverpod']));
      expect(post.reactions, equals(42));
      expect(post.views, equals(150));
      expect(post.userId, equals(5));
    });

    test('fromJson gere les champs manquants avec des valeurs par defaut', () {
      final json = <String, dynamic>{};
      final post = PostModel.fromJson(json);

      expect(post.id, equals(0));
      expect(post.title, equals(''));
      expect(post.body, equals(''));
      expect(post.tags, isEmpty);
      expect(post.reactions, equals(0));
      expect(post.views, equals(0));
      expect(post.userId, equals(0));
    });

    test('toJson serialise correctement un PostModel', () {
      const post = PostModel(
        id: 7,
        title: 'Titre serialise',
        body: 'Corps du message',
        tags: ['test', 'json'],
        reactions: 10,
        views: 99,
        userId: 3,
      );

      final json = post.toJson();

      expect(json['id'], equals(7));
      expect(json['title'], equals('Titre serialise'));
      expect(json['body'], equals('Corps du message'));
      expect(json['tags'], containsAll(['test', 'json']));
      expect(json['reactions'], equals(10));
      expect(json['views'], equals(99));
      expect(json['userId'], equals(3));
    });

    test('fromJson gere reactions sous forme entier directement', () {
      final json = {
        'id': 2,
        'title': 'Test reactions int',
        'body': 'Body',
        'tags': <dynamic>[],
        'reactions': 5,
        'views': 0,
        'userId': 1,
      };

      final post = PostModel.fromJson(json);
      expect(post.reactions, equals(5));
    });
  });
}

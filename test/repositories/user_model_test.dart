import 'package:flutter_test/flutter_test.dart';
import 'package:connected_app/features/auth/data/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parse correctement un utilisateur DummyJSON', () {
      final json = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@example.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'gender': 'female',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'accessToken': 'mock.jwt.token',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals(1));
      expect(user.username, equals('emilys'));
      expect(user.email, equals('emily.johnson@example.com'));
      expect(user.firstName, equals('Emily'));
      expect(user.lastName, equals('Johnson'));
      expect(user.fullName, equals('Emily Johnson'));
      expect(user.token, equals('mock.jwt.token'));
    });

    test('fullName concatene correctement prenom et nom', () {
      final user = UserModel.fromJson({
        'id': 2,
        'username': 'test',
        'email': 'test@test.com',
        'firstName': 'Jean',
        'lastName': 'Dupont',
        'gender': 'male',
        'image': '',
      });

      expect(user.fullName, equals('Jean Dupont'));
    });

    test('fromJson gere les valeurs par defaut si champs absents', () {
      final json = <String, dynamic>{};
      final user = UserModel.fromJson(json);

      expect(user.id, equals(0));
      expect(user.username, equals(''));
      expect(user.email, equals(''));
      expect(user.fullName, equals(''));
      expect(user.token, isNull);
    });

    test('toJson serialise et peut etre recharge avec fromJson', () {
      final original = UserModel.fromJson({
        'id': 5,
        'username': 'johnd',
        'email': 'john.doe@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'gender': 'male',
        'image': 'https://example.com/photo.png',
        'token': 'mytoken',
      });

      final json = original.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.username, equals(original.username));
      expect(restored.fullName, equals(original.fullName));
    });
  });
}

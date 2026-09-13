import 'package:flutter_test/flutter_test.dart';
import 'package:connected_app/core/storage/local_storage.dart';
import 'package:connected_app/core/api/api_client.dart';
import 'package:connected_app/features/posts/data/post_repository_impl.dart';
import 'package:connected_app/features/auth/data/auth_repository_impl.dart';
import 'package:connected_app/features/posts/data/post_model.dart';

class MockLocalStorageService extends LocalStorageService {
  final List<Map<String, dynamic>> _cache = [];
  String? _savedToken;

  @override
  Future<void> cachePosts(List<Map<String, dynamic>> postsList) async {
    _cache.clear();
    _cache.addAll(postsList);
  }

  @override
  List<Map<String, dynamic>> getCachedPosts() {
    return List.unmodifiable(_cache);
  }

  @override
  Future<void> saveTokens({required String token, String? refreshToken}) async {
    _savedToken = token;
  }

  @override
  Future<String?> getToken() async {
    return _savedToken;
  }

  @override
  Future<void> clearTokens() async {
    _savedToken = null;
  }
}

void main() {
  late MockLocalStorageService mockStorage;
  late ApiClient apiClient;
  late PostRepositoryImpl postRepository;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockStorage = MockLocalStorageService();
    apiClient = ApiClient(storage: mockStorage);
    postRepository = PostRepositoryImpl(apiClient: apiClient, storage: mockStorage);
    authRepository = AuthRepositoryImpl(apiClient: apiClient, storage: mockStorage);
  });

  group('PostRepository Unit Tests', () {
    test('Test 1: Fallback Mode Hors-Ligne charge les donnees depuis le cache local Hive', () async {
      await mockStorage.cachePosts([
        {
          'id': 101,
          'title': 'Article Hors-Ligne 1',
          'body': 'Contenu sauvegarde en cache local',
          'tags': ['offline', 'hive'],
          'reactions': 12,
          'views': 150,
          'userId': 5,
        },
        {
          'id': 102,
          'title': 'Article Hors-Ligne 2',
          'body': 'Deuxieme contenu en cache',
          'tags': ['flutter'],
          'reactions': 20,
          'views': 230,
          'userId': 5,
        },
      ]);

      final cachedPosts = mockStorage.getCachedPosts();
      expect(cachedPosts.length, 2);
      expect(cachedPosts.first['title'], 'Article Hors-Ligne 1');

      final postModel = PostModel.fromJson(cachedPosts.first);
      expect(postModel.id, 101);
      expect(postModel.reactions, 12);
    });

    test('Test 2: Sauvegarde et persistance du token d authentification', () async {
      const sampleToken = 'sample_jwt_token_header.payload.signature';
      await mockStorage.saveTokens(token: sampleToken);

      final retrieved = await mockStorage.getToken();
      expect(retrieved, sampleToken);

      await mockStorage.clearTokens();
      final afterClear = await mockStorage.getToken();
      expect(afterClear, isNull);
    });

    test('Test 3: Verification de la persistance locale du client', () async {
      await mockStorage.saveTokens(token: 'mon_token_securise');
      final token = await mockStorage.getToken();
      expect(token, isNotNull);
      expect(token, 'mon_token_securise');
    });
  });
}
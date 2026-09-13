import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/post_entity.dart';
import '../domain/post_repository.dart';
import 'post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final ApiClient apiClient;
  final LocalStorageService storage;

  PostRepositoryImpl({
    required this.apiClient,
    required this.storage,
  });

  @override
  Future<PostsResult> getPosts({String? query}) async {
    final hasQuery = query != null && query.trim().isNotEmpty;
    final endpoint = hasQuery
        ? '/posts/search?q=${Uri.encodeComponent(query.trim())}'
        : '/posts?limit=30';

    try {
      final response = await apiClient.dio.get(endpoint);
      final List<dynamic> listRaw =
          response.data['posts'] as List<dynamic>? ?? [];
      final posts =
          listRaw.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();

      // Mise en cache locale Hive des derniers articles
      if (!hasQuery) {
        await storage.cachePosts(posts.map((p) => p.toJson()).toList());
      }

      return PostsResult(posts: posts, isOffline: false);
    } on DioException catch (e) {
      // MODE HORS-LIGNE : Fallback sur le cache Hive si pas de reseau
      final cachedList = storage.getCachedPosts();
      if (cachedList.isNotEmpty) {
        final cachedPosts = cachedList.map((m) => PostModel.fromJson(m)).toList();
        return PostsResult(posts: cachedPosts, isOffline: true);
      }

      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw NetworkException(
          e.message ?? 'Impossible de charger les donnees et aucun cache local disponible.');
    }
  }

  @override
  Future<PostEntity> getPostById(int id) async {
    try {
      final response = await apiClient.dio.get('/posts/$id');
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Tentative de recherche dans le cache
      final cachedList = storage.getCachedPosts();
      try {
        final found = cachedList.firstWhere((item) => item['id'] == id);
        return PostModel.fromJson(found);
      } catch (_) {}

      if (e.error is ApiException) throw e.error as ApiException;
      throw const NetworkException(
          'Impossible de charger le detail de cet article.');
    }
  }
}

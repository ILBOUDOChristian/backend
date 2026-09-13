import 'post_entity.dart';

class PostsResult {
  final List<PostEntity> posts;
  final bool isOffline;

  const PostsResult({
    required this.posts,
    required this.isOffline,
  });
}

abstract class PostRepository {
  Future<PostsResult> getPosts({String? query});
  Future<PostEntity> getPostById(int id);
}

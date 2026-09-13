import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di.dart';
import '../domain/post_entity.dart';

class PostsState {
  final List<PostEntity> posts;
  final bool isLoading;
  final bool isOffline;
  final String? errorMessage;
  final String searchQuery;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isOffline = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  PostsState copyWith({
    List<PostEntity>? posts,
    bool? isLoading,
    bool? isOffline,
    String? errorMessage,
    String? searchQuery,
    bool clearError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  final Ref ref;

  PostsNotifier(this.ref) : super(const PostsState()) {
    loadPosts();
  }

  Future<void> loadPosts({String? query}) async {
    state = state.copyWith(isLoading: true, clearError: true, searchQuery: query ?? state.searchQuery);
    try {
      final result = await ref.read(postRepositoryProvider).getPosts(query: query ?? state.searchQuery);
      state = state.copyWith(
        posts: result.posts,
        isOffline: result.isOffline,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    loadPosts(query: query);
  }
}

final postsNotifierProvider =
    StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier(ref);
});

final postDetailFutureProvider =
    FutureProvider.family<PostEntity, int>((ref, postId) async {
  return await ref.read(postRepositoryProvider).getPostById(postId);
});

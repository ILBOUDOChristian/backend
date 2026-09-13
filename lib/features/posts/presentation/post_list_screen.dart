import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_detail_screen.dart';
import 'posts_controller.dart';

class PostListScreen extends ConsumerWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(postsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Articles REST (DummyJSON)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Banniere Mode Hors-Ligne
          if (postsState.isOffline)
            Container(
              width: double.infinity,
              color: Colors.amber.shade800,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Mode Hors-Ligne : donnees chargees depuis le cache Hive',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SearchBar(
              hintText: 'Rechercher dans l API REST...',
              leading: const Icon(Icons.search),
              onChanged: (query) {
                ref.read(postsNotifierProvider.notifier).setSearchQuery(query);
              },
            ),
          ),
          // Liste ou etats de chargement / erreur
          Expanded(
            child: Builder(
              builder: (context) {
                if (postsState.isLoading && postsState.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (postsState.errorMessage != null && postsState.posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: 64, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur reseau',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(postsState.errorMessage!,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                ref.read(postsNotifierProvider.notifier).loadPosts(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (postsState.posts.isEmpty) {
                  return const Center(child: Text('Aucun article trouve.'));
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(postsNotifierProvider.notifier).loadPosts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: postsState.posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final post = postsState.posts[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            post.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              post.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PostDetailScreen(postId: post.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

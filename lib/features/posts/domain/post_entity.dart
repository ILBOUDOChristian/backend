class PostEntity {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int reactions;
  final int views;
  final int userId;

  const PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.reactions,
    required this.views,
    required this.userId,
  });
}

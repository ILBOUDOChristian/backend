import '../domain/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.tags,
    required super.reactions,
    required super.views,
    required super.userId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    int reactionsCount = 0;
    if (json['reactions'] is Map) {
      reactionsCount = (json['reactions']['likes'] as int? ?? 0);
    } else if (json['reactions'] is int) {
      reactionsCount = json['reactions'] as int;
    }

    final tagsRaw = json['tags'] as List<dynamic>? ?? [];

    return PostModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tags: tagsRaw.map((e) => e.toString()).toList(),
      reactions: reactionsCount,
      views: json['views'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'tags': tags,
      'reactions': reactions,
      'views': views,
      'userId': userId,
    };
  }
}

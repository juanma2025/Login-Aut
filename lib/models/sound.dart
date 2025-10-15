class Sound {
  final String id;
  final String name;
  final String tag;
  final String url;
  final String userId;
  final DateTime createdAt;

  const Sound({
    required this.id,
    required this.name,
    required this.tag,
    required this.url,
    required this.userId,
    required this.createdAt,
  });

  factory Sound.fromMap(Map<String, dynamic> map) {
    return Sound(
      id: map['id'] as String,
      name: map['name'] as String,
      tag: map['tag'] as String,
      url: map['url'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'url': url,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
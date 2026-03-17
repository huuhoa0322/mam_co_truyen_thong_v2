class FamilySecret {
  final int? id;
  final int? dishId;
  final String? title;
  final String content;
  final String? coverImageUrl;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FamilySecret({
    this.id,
    this.dishId,
    this.title,
    required this.content,
    this.coverImageUrl,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  FamilySecret copyWith({
    int? id,
    int? dishId,
    String? title,
    String? content,
    String? coverImageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilySecret(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

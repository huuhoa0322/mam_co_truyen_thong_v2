import 'dart:convert';

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

  factory FamilySecret.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'] is String) {
      try {
        parsedTags = List<String>.from(json.decode(map['tags']));
      } catch (e) {
        parsedTags = [];
      }
    }

    return FamilySecret(
      id: map['id'] as int?,
      dishId: map['dish_id'] as int?,
      title: map['title'] as String?,
      content: map['content'] as String,
      coverImageUrl: map['cover_image_url'] as String?,
      tags: parsedTags,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (title != null) 'title': title,
      'content': content,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      'tags': json.encode(tags),
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

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

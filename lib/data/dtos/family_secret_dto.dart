import 'dart:convert';
import '../../domain/entities/family_secret.dart';

class FamilySecretDto {
  static FamilySecret fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'] is String) {
      try {
        parsedTags = List<String>.from(json.decode(map['tags']));
      } catch (_) {}
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

  static Map<String, dynamic> toMap(FamilySecret secret) {
    return {
      if (secret.id != null) 'id': secret.id,
      if (secret.dishId != null) 'dish_id': secret.dishId,
      if (secret.title != null) 'title': secret.title,
      'content': secret.content,
      if (secret.coverImageUrl != null) 'cover_image_url': secret.coverImageUrl,
      'tags': json.encode(secret.tags),
      if (secret.createdAt != null) 'created_at': secret.createdAt!.toIso8601String(),
      if (secret.updatedAt != null) 'updated_at': secret.updatedAt!.toIso8601String(),
    };
  }
}

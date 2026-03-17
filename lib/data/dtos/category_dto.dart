import '../../domain/entities/category.dart';

class CategoryDto {
  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      coverImageUrl: map['cover_image_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  static Map<String, dynamic> toMap(Category category) {
    return {
      if (category.id != null) 'id': category.id,
      'name': category.name,
      if (category.coverImageUrl != null)
        'cover_image_url': category.coverImageUrl,
      if (category.createdAt != null)
        'created_at': category.createdAt!.toIso8601String(),
      if (category.updatedAt != null)
        'updated_at': category.updatedAt!.toIso8601String(),
    };
  }
}

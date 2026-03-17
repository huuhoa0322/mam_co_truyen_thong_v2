import '../../domain/entities/dish.dart';

class DishDto {
  static Dish fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      calories: map['calories'] as int?,
      servingsMin: map['servings_min'] as int? ?? 2,
      servingsMax: map['servings_max'] as int? ?? 4,
      cookTimeMinutes: map['cook_time_minutes'] as int? ?? 30,
      difficulty: map['difficulty'] as String? ?? 'Dễ',
      originPerson: map['origin_person'] as String?,
      originNote: map['origin_note'] as String?,
      isFeatured: map['is_featured'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  static Map<String, dynamic> toMap(Dish dish) {
    return {
      if (dish.id != null) 'id': dish.id,
      if (dish.categoryId != null) 'category_id': dish.categoryId,
      'name': dish.name,
      if (dish.description != null) 'description': dish.description,
      if (dish.imageUrl != null) 'image_url': dish.imageUrl,
      if (dish.calories != null) 'calories': dish.calories,
      'servings_min': dish.servingsMin,
      'servings_max': dish.servingsMax,
      'cook_time_minutes': dish.cookTimeMinutes,
      'difficulty': dish.difficulty,
      if (dish.originPerson != null) 'origin_person': dish.originPerson,
      if (dish.originNote != null) 'origin_note': dish.originNote,
      'is_featured': dish.isFeatured ? 1 : 0,
      if (dish.createdAt != null)
        'created_at': dish.createdAt!.toIso8601String(),
      if (dish.updatedAt != null)
        'updated_at': dish.updatedAt!.toIso8601String(),
    };
  }
}

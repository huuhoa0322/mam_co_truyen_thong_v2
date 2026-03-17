import '../../domain/entities/recipe_ingredient.dart';

class RecipeIngredientDto {
  static RecipeIngredient fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id'] as int?,
      dishId: map['dish_id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
      notes: map['notes'] as String?,
      isChecked: map['is_checked'] == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  static Map<String, dynamic> toMap(RecipeIngredient item) {
    return {
      if (item.id != null) 'id': item.id,
      'dish_id': item.dishId,
      'name': item.name,
      'amount': item.amount,
      'unit': item.unit,
      if (item.notes != null) 'notes': item.notes,
      'is_checked': item.isChecked ? 1 : 0,
      if (item.createdAt != null) 'created_at': item.createdAt!.toIso8601String(),
      if (item.updatedAt != null) 'updated_at': item.updatedAt!.toIso8601String(),
    };
  }
}

import '../../domain/entities/shopping_item.dart';

class ShoppingItemDto {
  static ShoppingItem fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      dishId: map['dish_id'] as int?,
      ingredientName: map['ingredient_name'] as String,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      unit: map['unit'] as String? ?? 'cái',
      estimatedPrice: map['estimated_price'] as int? ?? 0,
      actualPrice: map['actual_price'] as int?,
      isChecked: map['is_checked'] == 1,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  static Map<String, dynamic> toMap(ShoppingItem item) {
    return {
      if (item.id != null) 'id': item.id,
      if (item.dishId != null) 'dish_id': item.dishId,
      'ingredient_name': item.ingredientName,
      'quantity': item.quantity,
      'unit': item.unit,
      'estimated_price': item.estimatedPrice,
      if (item.actualPrice != null) 'actual_price': item.actualPrice,
      'is_checked': item.isChecked ? 1 : 0,
      if (item.notes != null) 'notes': item.notes,
      if (item.createdAt != null) 'created_at': item.createdAt?.toIso8601String(),
      if (item.updatedAt != null) 'updated_at': item.updatedAt?.toIso8601String(),
    };
  }
}

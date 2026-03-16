class ShoppingItem {
  final int? id;
  final int? dishId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final int estimatedPrice;
  final int? actualPrice;
  final bool isChecked;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShoppingItem({
    this.id,
    this.dishId,
    required this.ingredientName,
    this.quantity = 1,
    this.unit = 'cái',
    this.estimatedPrice = 0,
    this.actualPrice,
    this.isChecked = false,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
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
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      'ingredient_name': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'estimated_price': estimatedPrice,
      if (actualPrice != null) 'actual_price': actualPrice,
      'is_checked': isChecked ? 1 : 0,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ShoppingItem copyWith({
    int? id,
    int? dishId,
    String? ingredientName,
    double? quantity,
    String? unit,
    int? estimatedPrice,
    int? actualPrice,
    bool? isChecked,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      isChecked: isChecked ?? this.isChecked,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

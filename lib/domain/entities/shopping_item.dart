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

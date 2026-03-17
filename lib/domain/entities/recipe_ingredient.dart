class RecipeIngredient {
  final int? id;
  final int dishId;
  final String name;
  final double amount;
  final String unit;
  final String? notes;
  final bool isChecked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecipeIngredient({
    this.id,
    required this.dishId,
    required this.name,
    required this.amount,
    required this.unit,
    this.notes,
    this.isChecked = false,
    this.createdAt,
    this.updatedAt,
  });

  RecipeIngredient copyWith({
    int? id,
    int? dishId,
    String? name,
    double? amount,
    String? unit,
    String? notes,
    bool? isChecked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

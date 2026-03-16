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

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'dish_id': dishId,
      'name': name,
      'amount': amount,
      'unit': unit,
      if (notes != null) 'notes': notes,
      'is_checked': isChecked ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

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

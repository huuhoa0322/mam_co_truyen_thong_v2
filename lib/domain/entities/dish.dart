class Dish {
  final int? id;
  final int? categoryId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? calories;
  final int servingsMin;
  final int servingsMax;
  final int cookTimeMinutes;
  final String difficulty;
  final String? originPerson;
  final String? originNote;
  final bool isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Dish({
    this.id,
    this.categoryId,
    required this.name,
    this.description,
    this.imageUrl,
    this.calories,
    this.servingsMin = 2,
    this.servingsMax = 4,
    this.cookTimeMinutes = 30,
    this.difficulty = 'Dễ',
    this.originPerson,
    this.originNote,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  Dish copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    String? imageUrl,
    int? calories,
    int? servingsMin,
    int? servingsMax,
    int? cookTimeMinutes,
    String? difficulty,
    String? originPerson,
    String? originNote,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dish(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      servingsMin: servingsMin ?? this.servingsMin,
      servingsMax: servingsMax ?? this.servingsMax,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      originPerson: originPerson ?? this.originPerson,
      originNote: originNote ?? this.originNote,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

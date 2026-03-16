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

  factory Dish.fromMap(Map<String, dynamic> map) {
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
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (calories != null) 'calories': calories,
      'servings_min': servingsMin,
      'servings_max': servingsMax,
      'cook_time_minutes': cookTimeMinutes,
      'difficulty': difficulty,
      if (originPerson != null) 'origin_person': originPerson,
      if (originNote != null) 'origin_note': originNote,
      'is_featured': isFeatured ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

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

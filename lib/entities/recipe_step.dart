class RecipeStep {
  final int? id;
  final int dishId;
  final int stepNumber;
  final String title;
  final String description;
  final int? timerMinutes;
  final String? timerLabel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecipeStep({
    this.id,
    required this.dishId,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.timerMinutes,
    this.timerLabel,
    this.createdAt,
    this.updatedAt,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: map['id'] as int?,
      dishId: map['dish_id'] as int,
      stepNumber: map['step_number'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      timerMinutes: map['timer_minutes'] as int?,
      timerLabel: map['timer_label'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'dish_id': dishId,
      'step_number': stepNumber,
      'title': title,
      'description': description,
      if (timerMinutes != null) 'timer_minutes': timerMinutes,
      if (timerLabel != null) 'timer_label': timerLabel,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  RecipeStep copyWith({
    int? id,
    int? dishId,
    int? stepNumber,
    String? title,
    String? description,
    int? timerMinutes,
    String? timerLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      timerLabel: timerLabel ?? this.timerLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

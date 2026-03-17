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

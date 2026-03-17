import '../../domain/entities/recipe_step.dart';

class RecipeStepDto {
  static RecipeStep fromMap(Map<String, dynamic> map) {
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

  static Map<String, dynamic> toMap(RecipeStep step) {
    return {
      if (step.id != null) 'id': step.id,
      'dish_id': step.dishId,
      'step_number': step.stepNumber,
      'title': step.title,
      'description': step.description,
      if (step.timerMinutes != null) 'timer_minutes': step.timerMinutes,
      if (step.timerLabel != null) 'timer_label': step.timerLabel,
      if (step.createdAt != null) 'created_at': step.createdAt!.toIso8601String(),
      if (step.updatedAt != null) 'updated_at': step.updatedAt!.toIso8601String(),
    };
  }
}

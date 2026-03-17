import '../../domain/entities/recipe_step.dart';

abstract class IRecipeStepRepository {
  Future<List<RecipeStep>> getByDish(int dishId);
  Future<void> create(RecipeStep step);
  Future<void> update(RecipeStep step);
  Future<void> delete(int id);
}

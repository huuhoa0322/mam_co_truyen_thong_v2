import '../../domain/entities/recipe_ingredient.dart';

abstract class IRecipeIngredientRepository {
  Future<List<RecipeIngredient>> getByDish(int dishId);
  Future<void> create(RecipeIngredient item);
  Future<void> update(RecipeIngredient item);
  Future<void> delete(int id);
}

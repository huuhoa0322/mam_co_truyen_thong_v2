import '../../data/dtos/recipe_ingredient_dto.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../implementations/local/app_database.dart';
import '../../interfaces/repositories/i_recipe_ingredient_repository.dart';

class LocalRecipeIngredientRepository implements IRecipeIngredientRepository {
  final AppDatabase _db;

  LocalRecipeIngredientRepository(this._db);

  @override
  Future<List<RecipeIngredient>> getByDish(int dishId) async {
    final db = await _db.database;
    final maps = await db.query(
      'recipe_ingredients',
      where: 'dish_id = ?',
      whereArgs: [dishId],
      orderBy: 'id ASC',
    );
    return maps.map(RecipeIngredientDto.fromMap).toList();
  }

  @override
  Future<void> create(RecipeIngredient item) async {
    final db = await _db.database;
    final newItem = item.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('recipe_ingredients', RecipeIngredientDto.toMap(newItem));
  }

  @override
  Future<void> update(RecipeIngredient item) async {
    final db = await _db.database;
    final updated = item.copyWith(updatedAt: DateTime.now());
    await db.update(
      'recipe_ingredients',
      RecipeIngredientDto.toMap(updated),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('recipe_ingredients', where: 'id = ?', whereArgs: [id]);
  }
}

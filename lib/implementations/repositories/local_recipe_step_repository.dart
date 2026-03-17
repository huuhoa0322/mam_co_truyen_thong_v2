import '../../data/dtos/recipe_step_dto.dart';
import '../../domain/entities/recipe_step.dart';
import '../../implementations/local/app_database.dart';
import '../../interfaces/repositories/i_recipe_step_repository.dart';

class LocalRecipeStepRepository implements IRecipeStepRepository {
  final AppDatabase _db;

  LocalRecipeStepRepository(this._db);

  @override
  Future<List<RecipeStep>> getByDish(int dishId) async {
    final db = await _db.database;
    final maps = await db.query(
      'recipe_steps',
      where: 'dish_id = ?',
      whereArgs: [dishId],
      orderBy: 'step_number ASC',
    );
    return maps.map(RecipeStepDto.fromMap).toList();
  }

  @override
  Future<void> create(RecipeStep step) async {
    final db = await _db.database;
    final newStep = step.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('recipe_steps', RecipeStepDto.toMap(newStep));
  }

  @override
  Future<void> update(RecipeStep step) async {
    final db = await _db.database;
    final updated = step.copyWith(updatedAt: DateTime.now());
    await db.update(
      'recipe_steps',
      RecipeStepDto.toMap(updated),
      where: 'id = ?',
      whereArgs: [step.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('recipe_steps', where: 'id = ?', whereArgs: [id]);
  }
}

import '../../data/dtos/dish_dto.dart';
import '../../domain/entities/dish.dart';
import '../../implementations/local/app_database.dart';
import '../../interfaces/repositories/i_dish_repository.dart';

class LocalDishRepository implements IDishRepository {
  final AppDatabase _db;

  LocalDishRepository(this._db);

  @override
  Future<List<Dish>> getFeatured() async {
    final db = await _db.database;
    final maps = await db.query(
      'dishes',
      where: 'is_featured = ?',
      whereArgs: [1],
    );
    return maps.map(DishDto.fromMap).toList();
  }

  @override
  Future<List<Dish>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('dishes', orderBy: 'created_at DESC');
    return maps.map(DishDto.fromMap).toList();
  }

  @override
  Future<List<Dish>> getByCategory(int categoryId) async {
    final db = await _db.database;
    final maps = await db.query(
      'dishes',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map(DishDto.fromMap).toList();
  }

  @override
  Future<void> create(Dish dish) async {
    final db = await _db.database;
    await db.insert('dishes', DishDto.toMap(dish));
  }

  @override
  Future<void> update(Dish dish) async {
    final db = await _db.database;
    final updated = dish.copyWith(updatedAt: DateTime.now());
    await db.update(
      'dishes',
      DishDto.toMap(updated),
      where: 'id = ?',
      whereArgs: [dish.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('dishes', where: 'id = ?', whereArgs: [id]);
  }
}

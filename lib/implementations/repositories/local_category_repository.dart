import '../../data/dtos/category_dto.dart';
import '../../domain/entities/category.dart';
import '../../implementations/local/app_database.dart';
import '../../interfaces/repositories/i_category_repository.dart';

class LocalCategoryRepository implements ICategoryRepository {
  final AppDatabase _db;

  LocalCategoryRepository(this._db);

  @override
  Future<List<Category>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('categories');
    return maps.map(CategoryDto.fromMap).toList();
  }

  @override
  Future<void> create(Category category) async {
    final db = await _db.database;
    await db.insert('categories', CategoryDto.toMap(category));
  }

  @override
  Future<void> update(Category category) async {
    final db = await _db.database;
    final updated = category.copyWith(updatedAt: DateTime.now());
    await db.update(
      'categories',
      CategoryDto.toMap(updated),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}

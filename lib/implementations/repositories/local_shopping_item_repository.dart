import '../local/app_database.dart';
import '../../data/dtos/shopping_item_dto.dart';
import '../../domain/entities/shopping_item.dart';
import '../../interfaces/repositories/i_shopping_item_repository.dart';

class LocalShoppingItemRepository implements IShoppingItemRepository {
  final AppDatabase _dbHelper;

  LocalShoppingItemRepository(this._dbHelper);

  @override
  Future<List<ShoppingItem>> getByDish(int dishId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shopping_items',
      where: 'dish_id = ?',
      whereArgs: [dishId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => ShoppingItemDto.fromMap(map)).toList();
  }

  @override
  Future<void> create(ShoppingItem item) async {
    final db = await _dbHelper.database;
    await db.insert('shopping_items', ShoppingItemDto.toMap(item));
  }

  @override
  Future<void> createBatch(List<ShoppingItem> items) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('shopping_items', ShoppingItemDto.toMap(item));
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> update(ShoppingItem item) async {
    if (item.id == null) return;
    final db = await _dbHelper.database;
    final map = ShoppingItemDto.toMap(item);
    map['updated_at'] = DateTime.now().toIso8601String();
    
    await db.update(
      'shopping_items',
      map,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

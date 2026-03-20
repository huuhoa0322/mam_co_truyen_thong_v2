import '../../domain/entities/shopping_item.dart';

abstract class IShoppingItemRepository {
  Future<List<ShoppingItem>> getByDish(int dishId);
  Future<void> create(ShoppingItem item);
  Future<void> createBatch(List<ShoppingItem> items);
  Future<void> update(ShoppingItem item);
  Future<void> delete(int id);
}

import '../../domain/entities/dish.dart';

abstract class IDishRepository {
  Future<List<Dish>> getFeatured();
  Future<List<Dish>> getAll();
  Future<List<Dish>> getByCategory(int categoryId);
  Future<Dish?> getById(int id);
  Future<int> create(Dish dish);
  Future<void> update(Dish dish);
  Future<void> delete(int id);
}

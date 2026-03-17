import '../../domain/entities/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getAll();
  Future<void> create(Category category);
  Future<void> update(Category category);
  Future<void> delete(int id);
}

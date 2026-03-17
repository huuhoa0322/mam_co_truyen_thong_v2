import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/dish.dart'; 
import '../../implementations/local/app_database.dart';

class HomeViewModel extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Dish> _featuredDishes = [];
  List<Dish> get featuredDishes => _featuredDishes;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Dish> _recentDishes = [];
  List<Dish> get recentDishes => _recentDishes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeViewModel() {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await _db.database;
      
      // 1. Load Featured Dishes (is_featured = 1)
      final featuredQuery = await db.query(
        'dishes',
        where: 'is_featured = ?',
        whereArgs: [1],
      );
      _featuredDishes = featuredQuery.map((e) => Dish.fromMap(e)).toList();

      // 2. Load Categories
      final categoryQuery = await db.query('categories');
      _categories = categoryQuery.map((e) => Category.fromMap(e)).toList();

      // 3. Load Recent Dishes (tất cả)
      final recentQuery = await db.query(
        'dishes',
        orderBy: 'created_at DESC',
      );
      _recentDishes = recentQuery.map((e) => Dish.fromMap(e)).toList();

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Dish>> getDishesByCategory(int categoryId) async {
    try {
      final db = await _db.database;
      final results = await db.query(
        'dishes',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
      return results.map((e) => Dish.fromMap(e)).toList();
    } catch (e) {
      print('Get Dishes By Category Error: $e');
      return [];
    }
  }

  Future<void> createCategory(String name, String imagePath) async {
    try {
      final db = await _db.database;
      final newCategory = Category(
        name: name,
        coverImageUrl: imagePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final id = await db.insert('categories', newCategory.toMap());
      final insertedCategory = newCategory.copyWith(id: id);
      
      _categories.add(insertedCategory);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createDish(Dish dish) async {
    try {
      final db = await _db.database;
      await db.insert('dishes', dish.toMap());
      
      // Refresh to get the latest 3 correctly and updated featured list if necessary
      await loadHomeData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      final db = await _db.database;
      final updatedCat = category.copyWith(updatedAt: DateTime.now());
      await db.update(
        'categories',
        updatedCat.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
      
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = updatedCat;
        notifyListeners();
      }
    } catch (e) {
      print('Update Category Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final db = await _db.database;
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      print('Delete Category Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDish(Dish dish) async {
    try {
      final db = await _db.database;
      final updatedDish = dish.copyWith(updatedAt: DateTime.now());
      await db.update(
        'dishes',
        updatedDish.toMap(),
        where: 'id = ?',
        whereArgs: [dish.id],
      );
      await loadHomeData();
    } catch (e) {
      print('Update Dish Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDish(int id) async {
    try {
      final db = await _db.database;
      await db.delete('dishes', where: 'id = ?', whereArgs: [id]);
      await loadHomeData();
    } catch (e) {
      print('Delete Dish Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

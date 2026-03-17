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

      // 3. Load Recent Dishes (latest 3)
      final recentQuery = await db.query(
        'dishes',
        orderBy: 'created_at DESC',
        limit: 3,
      );
      _recentDishes = recentQuery.map((e) => Dish.fromMap(e)).toList();

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
}

import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/dish.dart';
import '../../interfaces/repositories/i_category_repository.dart';
import '../../interfaces/repositories/i_dish_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ICategoryRepository _categoryRepo;
  final IDishRepository _dishRepo;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Dish> _featuredDishes = [];
  List<Dish> get featuredDishes => _featuredDishes;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Dish> _recentDishes = [];
  List<Dish> get recentDishes => _recentDishes;
  List<Dish> get allDishes => _recentDishes; // All dishes from database

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeViewModel({
    required ICategoryRepository categoryRepo,
    required IDishRepository dishRepo,
  })  : _categoryRepo = categoryRepo,
        _dishRepo = dishRepo {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _featuredDishes = await _dishRepo.getFeatured();
      _categories = await _categoryRepo.getAll();
      _recentDishes = await _dishRepo.getAll();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Dish>> getDishesByCategory(int categoryId) async {
    try {
      return await _dishRepo.getByCategory(categoryId);
    } catch (e) {
      debugPrint('Get Dishes By Category Error: $e');
      return [];
    }
  }

  // ── Category CRUD ────────────────────────────────────────────────────────

  Future<void> createCategory(String name, String imagePath) async {
    try {
      final category = Category(
        name: name,
        coverImageUrl: imagePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _categoryRepo.create(category);
      await loadHomeData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoryRepo.update(category);
      await loadHomeData();
    } catch (e) {
      debugPrint('Update Category Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryRepo.delete(id);
      await loadHomeData();
    } catch (e) {
      debugPrint('Delete Category Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Dish CRUD ────────────────────────────────────────────────────────────

  Future<void> createDish(Dish dish) async {
    try {
      await _dishRepo.create(dish);
      await loadHomeData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDish(Dish dish) async {
    try {
      await _dishRepo.update(dish);
      await loadHomeData();
    } catch (e) {
      debugPrint('Update Dish Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDish(int id) async {
    try {
      await _dishRepo.delete(id);
      await loadHomeData();
    } catch (e) {
      debugPrint('Delete Dish Error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

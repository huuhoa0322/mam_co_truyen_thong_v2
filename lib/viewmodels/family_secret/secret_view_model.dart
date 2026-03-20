import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/family_secret.dart';
import '../../interfaces/repositories/i_category_repository.dart';
import '../../interfaces/repositories/i_dish_repository.dart';
import '../../interfaces/repositories/i_family_secret_repository.dart';

class SecretViewModel extends ChangeNotifier {
  final IFamilySecretRepository _secretRepo;
  final IDishRepository _dishRepo;
  final ICategoryRepository _categoryRepo;

  SecretViewModel({
    required IFamilySecretRepository secretRepo,
    required IDishRepository dishRepo,
    required ICategoryRepository categoryRepo,
  })  : _secretRepo = secretRepo,
        _dishRepo = dishRepo,
        _categoryRepo = categoryRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<FamilySecret> _allSecrets = [];
  List<FamilySecret> _filteredSecrets = [];
  List<FamilySecret> get filteredSecrets => _filteredSecrets;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Dish> _availableDishes = [];
  List<Dish> get availableDishes => _availableDishes;

  Category? _selectedCategory;
  Category? get selectedCategory => _selectedCategory;

  Future<void> init() async {
    _setLoading(true);
    try {
      _categories = await _categoryRepo.getAll();
      _availableDishes = await _dishRepo.getAll();
      _allSecrets = await _secretRepo.getAll();
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void setFilter(Category? category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedCategory == null) {
      _filteredSecrets = List.from(_allSecrets);
    } else {
      // Find dishes belonging to the selected category
      final dishIdsInCategory = _availableDishes
          .where((d) => d.categoryId == _selectedCategory!.id)
          .map((d) => d.id)
          .toSet();

      _filteredSecrets = _allSecrets
          .where((s) => dishIdsInCategory.contains(s.dishId))
          .toList();
    }
  }

  Dish? getDishForSecret(FamilySecret secret) {
    if (secret.dishId == null) return null;
    return _availableDishes.where((d) => d.id == secret.dishId).firstOrNull;
  }

  Future<void> addSecret({
    Dish? existingDish,
    String? newDishName,
    int? newDishCategoryId,
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    try {
      _setLoading(true);

      int finalDishId;

      if (existingDish != null) {
        finalDishId = existingDish.id!;
      } else if (newDishName != null && newDishName.isNotEmpty) {
        // Create new dish
        final newDish = Dish(
          categoryId: newDishCategoryId ?? 1, // Fallback
          name: newDishName,
          description: '', 
          servingsMin: 1, 
          servingsMax: 1, 
          cookTimeMinutes: 30, 
          difficulty: 'Trung bình',
        );
        finalDishId = await _dishRepo.create(newDish);
        // Refresh available dishes so the new mapped structure works
        _availableDishes = await _dishRepo.getAll();
      } else {
        throw Exception('Phải chọn món hiện có hoặc nhập món mới.');
      }

      final newSecret = FamilySecret(
        dishId: finalDishId,
        title: title,
        content: content,
        tags: tags,
      );

      await _secretRepo.upsert(newSecret);
      _allSecrets = await _secretRepo.getAll();
      _applyFilter();
      _errorMessage = null;

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSecret(FamilySecret secret) async {
    try {
      _setLoading(true);
      await _secretRepo.upsert(secret);
      _allSecrets = await _secretRepo.getAll();
      _applyFilter();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSecret(int id) async {
    try {
      _setLoading(true);
      await _secretRepo.delete(id);
      _allSecrets = await _secretRepo.getAll();
      _applyFilter();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}

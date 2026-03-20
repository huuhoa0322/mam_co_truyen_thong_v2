import 'package:flutter/foundation.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/shopping_item.dart';
import '../../interfaces/repositories/i_dish_repository.dart';
import '../../interfaces/repositories/i_recipe_ingredient_repository.dart';
import '../../interfaces/repositories/i_shopping_item_repository.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final IShoppingItemRepository _shoppingRepo;
  final IDishRepository _dishRepo;
  final IRecipeIngredientRepository _ingredientRepo;

  ShoppingListViewModel({
    required IShoppingItemRepository shoppingRepo,
    required IDishRepository dishRepo,
    required IRecipeIngredientRepository ingredientRepo,
  })  : _shoppingRepo = shoppingRepo,
        _dishRepo = dishRepo,
        _ingredientRepo = ingredientRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Dish> _availableDishes = [];
  List<Dish> get availableDishes => _availableDishes;

  Dish? _selectedDish;
  Dish? get selectedDish => _selectedDish;

  List<ShoppingItem> _items = [];
  List<ShoppingItem> get items => _items;

  // Computed totals
  int get totalEstimatedBudget {
    return _items.fold(0, (sum, item) => sum + item.estimatedPrice);
  }

  int get totalActualSpent {
    return _items.fold(0, (sum, item) => sum + (item.actualPrice ?? 0));
  }

  Future<void> init([int? initialDishId]) async {
    _setLoading(true);
    try {
      // Load all available dishes
      _availableDishes = await _dishRepo.getAll();
      
      if (initialDishId != null) {
        // Find dish by ID and select it
        try {
          final dish = _availableDishes.firstWhere((d) => d.id == initialDishId);
          await selectDish(dish);
        } catch (e) {
          // If dish not found, do nothing, selectedDish remains null
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectDish(Dish dish) async {
    if (dish.id == null) return;
    _setLoading(true);
    try {
      _selectedDish = dish;
      List<ShoppingItem> loadedItems = await _shoppingRepo.getByDish(dish.id!);
      
      if (loadedItems.isEmpty) {
        // If no shopping items exist for this dish yet, we generate from ingredients
        final ingredients = await _ingredientRepo.getByDish(dish.id!);
        if (ingredients.isNotEmpty) {
          final newShoppingItems = ingredients.map((ing) {
            return ShoppingItem(
              dishId: dish.id,
              ingredientName: ing.name,
              quantity: ing.amount,
              unit: ing.unit,
              estimatedPrice: 0, // Users will input this later
            );
          }).toList();
          
          await _shoppingRepo.createBatch(newShoppingItems);
          loadedItems = await _shoppingRepo.getByDish(dish.id!);
        }
      }
      _items = loadedItems;
    } finally {
      _setLoading(false);
    }
  }

  void unselectDish() {
    _selectedDish = null;
    _items = [];
    notifyListeners();
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    if (_selectedDish?.id == null) return;
    
    // Ensure the item belongs to the selected dish
    final newItem = item.dishId == _selectedDish!.id 
      ? item 
      : item.copyWith(dishId: _selectedDish!.id);
      
    await _shoppingRepo.create(newItem);
    await _reloadItems();
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    await _shoppingRepo.update(item);
    await _reloadItems();
  }

  Future<void> toggleItemCheck(ShoppingItem item, bool isChecked) async {
    final updatedItem = item.copyWith(isChecked: isChecked);
    await updateShoppingItem(updatedItem);
  }

  Future<void> deleteShoppingItem(int id) async {
    await _shoppingRepo.delete(id);
    await _reloadItems();
  }

  Future<void> _reloadItems() async {
    if (_selectedDish?.id == null) return;
    _items = await _shoppingRepo.getByDish(_selectedDish!.id!);
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}

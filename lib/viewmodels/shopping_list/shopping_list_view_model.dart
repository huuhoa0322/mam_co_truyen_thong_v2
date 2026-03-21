import 'package:flutter/foundation.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/shopping_item.dart';
import '../../interfaces/repositories/i_dish_repository.dart';
import '../../interfaces/repositories/i_recipe_ingredient_repository.dart';
import '../../interfaces/repositories/i_shopping_item_repository.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../services/ai_service.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final IShoppingItemRepository _shoppingRepo;
  final IDishRepository _dishRepo;
  final IRecipeIngredientRepository _ingredientRepo;
  final AiService _aiService;

  ShoppingListViewModel({
    required IShoppingItemRepository shoppingRepo,
    required IDishRepository dishRepo,
    required IRecipeIngredientRepository ingredientRepo,
    required AiService aiService,
  })  : _shoppingRepo = shoppingRepo,
        _dishRepo = dishRepo,
        _ingredientRepo = ingredientRepo,
        _aiService = aiService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Dish> _availableDishes = [];
  List<Dish> get availableDishes => _availableDishes;

  Dish? _selectedDish;
  Dish? get selectedDish => _selectedDish;

  List<ShoppingItem> _items = [];
  List<ShoppingItem> get items => _items;

  bool _isEstimatingBudget = false;
  bool get isEstimatingBudget => _isEstimatingBudget;

  Future<void> suggestEstimatedPricePerItem() async {
    if (_selectedDish == null || _items.isEmpty) return;

    _isEstimatingBudget = true;
    notifyListeners();

    try {
      final ingredientList = _items
          .map((e) => '${e.ingredientName} | ${e.quantity} ${e.unit}')
          .toList();
      final drafts = await _aiService.suggestIngredientPriceDrafts(
        _selectedDish!.name,
        ingredientList,
      );

      if (drafts.isEmpty) return;

      final draftMap = {
        for (final draft in drafts)
          draft.ingredientName.toLowerCase().trim(): draft.estimatedPrice,
      };

      for (final item in _items) {
        final suggested = draftMap[item.ingredientName.toLowerCase().trim()];
        if (suggested == null || suggested <= 0) continue;

        final updated = item.copyWith(estimatedPrice: suggested);
        if (updated.id != null) {
          await _shoppingRepo.update(updated);
        } else {
          await _shoppingRepo.create(updated);
        }
      }

      await _reloadItems();
    } finally {
      _isEstimatingBudget = false;
      notifyListeners();
    }
  }

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
      await _reloadItems();
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
    
    // Add to ingredients first (Source of Truth)
    await _ingredientRepo.create(RecipeIngredient(
      dishId: _selectedDish!.id!,
      name: item.ingredientName,
      amount: item.quantity,
      unit: item.unit,
    ));

    // Also add to shopping list for pricing info
    final newItem = item.dishId == _selectedDish!.id 
      ? item 
      : item.copyWith(dishId: _selectedDish!.id);
      
    await _shoppingRepo.create(newItem);
    await _reloadItems();
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    if (_selectedDish?.id == null) return;

    // Update ingredients (Source of Truth) -> find by name
    final ings = await _ingredientRepo.getByDish(_selectedDish!.id!);
    final oldIng = ings.where((ing) => ing.name.toLowerCase() == item.ingredientName.toLowerCase()).firstOrNull;
    if (oldIng != null) {
      await _ingredientRepo.update(oldIng.copyWith(
        name: item.ingredientName,
        amount: item.quantity,
        unit: item.unit,
      ));
    }
    
    // Update shopping item if it exists, or create it
    if (item.id != null) {
      await _shoppingRepo.update(item);
    } else {
      await _shoppingRepo.create(item);
    }
    await _reloadItems();
  }

  Future<void> toggleItemCheck(ShoppingItem item, bool isChecked) async {
    final updatedItem = item.copyWith(isChecked: isChecked);
    await updateShoppingItem(updatedItem);
  }

  Future<void> deleteShoppingItem(ShoppingItem itemToDelete) async {
    // Delete from shopping items
    if (itemToDelete.id != null) {
      await _shoppingRepo.delete(itemToDelete.id!);
    }

    // Also delete from ingredients
    if (_selectedDish?.id != null) {
      final ings = await _ingredientRepo.getByDish(_selectedDish!.id!);
      final ing = ings.where((i) => i.name.toLowerCase() == itemToDelete.ingredientName.toLowerCase()).firstOrNull;
      if (ing?.id != null) {
        await _ingredientRepo.delete(ing!.id!);
      }
    }

    await _reloadItems();
  }

  Future<void> _reloadItems() async {
    if (_selectedDish?.id == null) return;
    
    // 1. Fetch Ingredients (Source of Truth)
    final ingredients = await _ingredientRepo.getByDish(_selectedDish!.id!);
    
    // 2. Fetch Pricing info from ShoppingItems
    final shoppingRecords = await _shoppingRepo.getByDish(_selectedDish!.id!);
    final shoppingMap = {
      for (var record in shoppingRecords) record.ingredientName.toLowerCase(): record
    };

    // 3. Merge them
    _items = ingredients.map((ing) {
      final record = shoppingMap[ing.name.toLowerCase()];
      return ShoppingItem(
        id: record?.id, // Could be null if pricing info wasn't created yet
        dishId: _selectedDish!.id!,
        ingredientName: ing.name,
        quantity: ing.amount,
        unit: ing.unit,
        estimatedPrice: record?.estimatedPrice ?? 0,
        actualPrice: record?.actualPrice,
        isChecked: record?.isChecked ?? false,
        notes: record?.notes,
      );
    }).toList();

    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}

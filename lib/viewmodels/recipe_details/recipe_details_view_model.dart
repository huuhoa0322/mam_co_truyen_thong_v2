import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/family_secret.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/recipe_step.dart';
import '../../interfaces/repositories/i_family_secret_repository.dart';
import '../../interfaces/repositories/i_recipe_ingredient_repository.dart';
import '../../interfaces/repositories/i_recipe_step_repository.dart';

class RecipeDetailsViewModel extends ChangeNotifier {
  final IRecipeIngredientRepository _ingredientRepo;
  final IRecipeStepRepository _stepRepo;
  final IFamilySecretRepository _secretRepo;

  RecipeDetailsViewModel({
    required IRecipeIngredientRepository ingredientRepo,
    required IRecipeStepRepository stepRepo,
    required IFamilySecretRepository secretRepo,
  })  : _ingredientRepo = ingredientRepo,
        _stepRepo = stepRepo,
        _secretRepo = secretRepo;

  // ── State ────────────────────────────────────────────────────────────────

  Dish? _dish;
  Dish? get dish => _dish;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RecipeIngredient> _ingredients = [];
  List<RecipeIngredient> get ingredients => _ingredients;

  List<RecipeStep> _steps = [];
  List<RecipeStep> get steps => _steps;

  FamilySecret? _familySecret;
  FamilySecret? get familySecret => _familySecret;

  // ── Global cook timer ────────────────────────────────────────────────────

  int _cookTimerSeconds = 0;
  int get cookTimerSeconds => _cookTimerSeconds;
  bool _isCookTimerRunning = false;
  bool get isCookTimerRunning => _isCookTimerRunning;
  Timer? _cookTimer;

  // ── Per-step timers ──────────────────────────────────────────────────────

  // Map<stepId, remainingSeconds>
  final Map<int, int> _stepTimerSeconds = {};
  final Map<int, bool> _stepTimerRunning = {};
  final Map<int, Timer?> _stepTimers = {};

  int stepTimerOf(int stepId) => _stepTimerSeconds[stepId] ?? 0;
  bool isStepTimerRunning(int stepId) => _stepTimerRunning[stepId] ?? false;

  // ── Load data ────────────────────────────────────────────────────────────

  Future<void> loadByDish(Dish dish) async {
    _dish = dish;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ingredients = await _ingredientRepo.getByDish(dish.id!);
      _steps = await _stepRepo.getByDish(dish.id!);
      _familySecret = await _secretRepo.getByDish(dish.id!);

      // Calculate total cook timer from steps
      final totalMinutes = _steps.fold<int>(
        0,
        (sum, s) => sum + (s.timerMinutes ?? 0),
      );
      _cookTimerSeconds = totalMinutes * 60;

      // Init per-step timers
      for (final step in _steps) {
        if (step.timerMinutes != null && step.id != null) {
          _stepTimerSeconds[step.id!] = step.timerMinutes! * 60;
          _stepTimerRunning[step.id!] = false;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDish() {
    _dish = null;
    _ingredients.clear();
    _steps.clear();
    _familySecret = null;
    
    // Clear global timer
    _cookTimer?.cancel();
    _cookTimer = null;
    _isCookTimerRunning = false;
    _cookTimerSeconds = 0;

    // Clear step timers
    for (var timer in _stepTimers.values) {
      timer?.cancel();
    }
    _stepTimers.clear();
    _stepTimerSeconds.clear();
    _stepTimerRunning.clear();

    notifyListeners();
  }

  // ── Cook timer controls ──────────────────────────────────────────────────

  void startCookTimer() {
    if (_isCookTimerRunning || _cookTimerSeconds <= 0) return;
    _isCookTimerRunning = true;
    _cookTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_cookTimerSeconds > 0) {
        _cookTimerSeconds--;
        notifyListeners();
      } else {
        stopCookTimer();
      }
    });
    notifyListeners();
  }

  void pauseCookTimer() {
    _cookTimer?.cancel();
    _isCookTimerRunning = false;
    notifyListeners();
  }

  void stopCookTimer() {
    _cookTimer?.cancel();
    _isCookTimerRunning = false;
    notifyListeners();
  }

  void resetCookTimer() {
    stopCookTimer();
    final totalMinutes = _steps.fold<int>(0, (sum, s) => sum + (s.timerMinutes ?? 0));
    _cookTimerSeconds = totalMinutes * 60;
    notifyListeners();
  }

  // ── Per-step timer controls ──────────────────────────────────────────────

  void startStepTimer(int stepId) {
    if (isStepTimerRunning(stepId) || stepTimerOf(stepId) <= 0) return;
    _stepTimerRunning[stepId] = true;
    _stepTimers[stepId] = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = (_stepTimerSeconds[stepId] ?? 0) - 1;
      if (remaining > 0) {
        _stepTimerSeconds[stepId] = remaining;
        notifyListeners();
      } else {
        _stepTimerSeconds[stepId] = 0;
        pauseStepTimer(stepId);
      }
    });
    notifyListeners();
  }

  void pauseStepTimer(int stepId) {
    _stepTimers[stepId]?.cancel();
    _stepTimerRunning[stepId] = false;
    notifyListeners();
  }

  void resetStepTimer(int stepId) {
    pauseStepTimer(stepId);
    final step = _steps.firstWhere((s) => s.id == stepId, orElse: () => _steps.first);
    _stepTimerSeconds[stepId] = (step.timerMinutes ?? 0) * 60;
    notifyListeners();
  }

  // ── Ingredient CRUD ──────────────────────────────────────────────────────

  Future<void> addIngredient(RecipeIngredient item) async {
    try {
      await _ingredientRepo.create(item);
      _ingredients = await _ingredientRepo.getByDish(_dish!.id!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateIngredient(RecipeIngredient item) async {
    try {
      await _ingredientRepo.update(item);
      _ingredients = await _ingredientRepo.getByDish(_dish!.id!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteIngredient(int id) async {
    try {
      await _ingredientRepo.delete(id);
      _ingredients.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleIngredientChecked(RecipeIngredient item) async {
    final updated = item.copyWith(isChecked: !item.isChecked);
    await updateIngredient(updated);
  }

  // ── Step CRUD ────────────────────────────────────────────────────────────

  Future<void> addStep(RecipeStep step) async {
    try {
      await _stepRepo.create(step);
      _steps = await _stepRepo.getByDish(_dish!.id!);
      _recalcCookTimer();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStep(RecipeStep step) async {
    try {
      await _stepRepo.update(step);
      _steps = await _stepRepo.getByDish(_dish!.id!);
      _recalcCookTimer();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteStep(int id) async {
    try {
      await _stepRepo.delete(id);
      _steps.removeWhere((s) => s.id == id);
      _recalcCookTimer();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _recalcCookTimer() {
    final totalMinutes = _steps.fold<int>(0, (sum, s) => sum + (s.timerMinutes ?? 0));
    _cookTimerSeconds = totalMinutes * 60;
  }

  // ── Family Secret CRUD ───────────────────────────────────────────────────

  Future<void> saveFamilySecret(FamilySecret secret) async {
    try {
      await _secretRepo.upsert(secret);
      _familySecret = await _secretRepo.getByDish(_dish!.id!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFamilySecret() async {
    if (_familySecret?.id == null) return;
    try {
      await _secretRepo.delete(_familySecret!.id!);
      _familySecret = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Timers formatting ────────────────────────────────────────────────────

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cookTimer?.cancel();
    for (final t in _stepTimers.values) {
      t?.cancel();
    }
    super.dispose();
  }
}

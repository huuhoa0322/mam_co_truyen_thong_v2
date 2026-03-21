import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/family_secret.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/recipe_step.dart';
import '../../interfaces/repositories/i_dish_repository.dart';
import '../../interfaces/repositories/i_family_secret_repository.dart';
import '../../interfaces/repositories/i_recipe_ingredient_repository.dart';
import '../../interfaces/repositories/i_recipe_step_repository.dart';

class RecipeDetailsViewModel extends ChangeNotifier {
  final IDishRepository _dishRepo;
  final IRecipeIngredientRepository _ingredientRepo;
  final IRecipeStepRepository _stepRepo;
  final IFamilySecretRepository _secretRepo;

  RecipeDetailsViewModel({
    required IDishRepository dishRepo,
    required IRecipeIngredientRepository ingredientRepo,
    required IRecipeStepRepository stepRepo,
    required IFamilySecretRepository secretRepo,
  })  : _dishRepo = dishRepo,
        _ingredientRepo = ingredientRepo,
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
  bool _isGlobalTimerSelected = true;
  bool get isGlobalTimerSelected => _isGlobalTimerSelected;
  Timer? _cookTimer;

  // ── Per-step timers ──────────────────────────────────────────────────────

  // Map<stepId, remainingSeconds>
  final Map<int, int> _stepTimerSeconds = {};
  final Map<int, int> _stepTimerInitialSeconds = {};
  final Map<int, bool> _stepTimerRunning = {};
  final Map<int, Timer?> _stepTimers = {};
  int? _activeStepTimerId;

  int stepTimerOf(int stepId) => _stepTimerSeconds[stepId] ?? 0;
  bool isStepTimerRunning(int stepId) => _stepTimerRunning[stepId] ?? false;

  RecipeStep? get activeStepTimerStep {
    final stepId = _activeStepTimerId;
    if (stepId == null) return null;
    for (final step in _steps) {
      if (step.id == stepId) return step;
    }
    return null;
  }

  bool get isInStepTimerMode => !_isCookTimerRunning && activeStepTimerStep != null;
  bool get canSelectStepTimer => !_isCookTimerRunning;
  bool get isActiveStepTimerRunning {
    final stepId = _activeStepTimerId;
    if (stepId == null) return false;
    return isStepTimerRunning(stepId);
  }

  String get cookBannerTitle {
    if (_isGlobalTimerSelected || _isCookTimerRunning) return 'Đang nấu...';
    final step = activeStepTimerStep;
    if (step == null) return 'Đang nấu...';
    return 'Bước ${step.stepNumber}: ${step.title}';
  }

  String get cookBannerSubtitle {
    if (_isGlobalTimerSelected || _isCookTimerRunning) return 'Đếm ngược toàn bộ';
    return activeStepTimerStep != null ? 'Đang thực hiện' : 'Đếm ngược toàn bộ';
  }

  int get cookBannerSeconds {
    if (_isGlobalTimerSelected || _isCookTimerRunning) return _cookTimerSeconds;
    final step = activeStepTimerStep;
    if (step?.id != null) {
      return stepTimerOf(step!.id!);
    }
    return _cookTimerSeconds;
  }

  bool get isBannerTimerRunning {
    if (_isGlobalTimerSelected) return _isCookTimerRunning;
    final stepId = _activeStepTimerId;
    if (stepId == null) return false;
    return isStepTimerRunning(stepId);
  }

  bool get isStepCrudLocked {
    if (_isGlobalTimerSelected && _isCookTimerRunning) return true;
    return _stepTimerRunning.values.any((isRunning) => isRunning);
  }

  // ── Load data ────────────────────────────────────────────────────────────

  Future<void> loadByDish(Dish dish) async {
    _dish = dish;
    _activeStepTimerId = null;
    _isGlobalTimerSelected = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (dish.id != null) {
        _dish = await _dishRepo.getById(dish.id!) ?? dish;
      }

      final dishId = _dish?.id;
      if (dishId == null) {
        _ingredients = [];
        _steps = [];
        _familySecret = null;
        _cookTimerSeconds = 0;
          _clearStepTimersState();
        return;
      }

      _ingredients = await _ingredientRepo.getByDish(dishId);
      _steps = await _stepRepo.getByDish(dishId);
      _familySecret = await _secretRepo.getByDish(dishId);

      // Calculate total cook timer from steps
      final totalMinutes = _steps.fold<int>(
        0,
        (sum, s) => sum + (s.timerMinutes ?? 0),
      );
      _cookTimerSeconds = totalMinutes * 60;

      _clearStepTimersState();

      // Init per-step timers
      for (final step in _steps) {
        if ((step.timerMinutes ?? 0) > 0 && step.id != null) {
          final initialSeconds = step.timerMinutes! * 60;
          _stepTimerSeconds[step.id!] = initialSeconds;
          _stepTimerInitialSeconds[step.id!] = initialSeconds;
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

  /// Cập nhật thông tin món ăn (khẩu phần, thời gian, độ khó)
  Future<void> updateDishInfo({
    int? servingsMin,
    int? servingsMax,
    int? cookTimeMinutes,
    String? difficulty,
  }) async {
    if (_dish == null) return;
    final updated = _dish!.copyWith(
      servingsMin: servingsMin,
      servingsMax: servingsMax,
      cookTimeMinutes: cookTimeMinutes,
      difficulty: difficulty,
    );
    await _dishRepo.update(updated);
    _dish = updated;
    notifyListeners();
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
    _stepTimerInitialSeconds.clear();
    _stepTimerRunning.clear();
    _activeStepTimerId = null;
    _isGlobalTimerSelected = true;

    notifyListeners();
  }

  // ── Cook timer controls ──────────────────────────────────────────────────

  void startCookTimer() {
    if (_isCookTimerRunning) return;

    if (_cookTimerSeconds <= 0) {
      _cookTimerSeconds = _totalInitialCookSeconds();
    }
    if (_cookTimerSeconds <= 0) {
      notifyListeners();
      return;
    }

    _pauseAllStepTimers(clearActiveSelection: false);

    _isCookTimerRunning = true;
    _cookTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _cookTimerSeconds - 1;
      _cookTimerSeconds = next > 0 ? next : 0;
      if (_cookTimerSeconds <= 0) {
        stopCookTimer();
        return;
      }

      notifyListeners();
    });
    notifyListeners();
  }

  void pauseCookTimer() {
    _cookTimer?.cancel();
    _cookTimer = null;
    _isCookTimerRunning = false;
    notifyListeners();
  }

  void stopCookTimer() {
    _cookTimer?.cancel();
    _cookTimer = null;
    _isCookTimerRunning = false;
    notifyListeners();
  }

  void resetCookTimer() {
    stopCookTimer();
    _resetAllStepTimersToInitial();
    _cookTimerSeconds = _totalInitialCookSeconds();
    notifyListeners();
  }

  // ── Per-step timer controls ──────────────────────────────────────────────

  void startStepTimer(int stepId) {
    if (_isCookTimerRunning) return;
    if (isStepTimerRunning(stepId) || stepTimerOf(stepId) <= 0) return;

    // Only one step timer can run at a time.
    for (final entry in _stepTimerRunning.entries) {
      final otherStepId = entry.key;
      final isRunning = entry.value;
      if (otherStepId != stepId && isRunning) {
        _stepTimers[otherStepId]?.cancel();
        _stepTimers[otherStepId] = null;
        _stepTimerRunning[otherStepId] = false;
      }
    }

    _activeStepTimerId = stepId;
    _stepTimerRunning[stepId] = true;
    _stepTimers[stepId]?.cancel();
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
    _stepTimers[stepId] = null;
    _stepTimerRunning[stepId] = false;
    notifyListeners();
  }

  void selectStepTimer(int stepId) {
    if (_isCookTimerRunning) return;
    if (!_stepTimerSeconds.containsKey(stepId)) return;

    final previousStepId = _activeStepTimerId;
    if (previousStepId != null && previousStepId != stepId && isStepTimerRunning(previousStepId)) {
      _pauseAllStepTimers(clearActiveSelection: false);
    }

    _activeStepTimerId = stepId;
    _isGlobalTimerSelected = false;
    notifyListeners();
  }

  void toggleBannerTimer() {
    if (_isGlobalTimerSelected) {
      if (_isCookTimerRunning) {
        pauseCookTimer();
      } else {
        startCookTimer();
      }
      return;
    }

    final stepId = _activeStepTimerId;
    if (stepId != null) {
      if (isStepTimerRunning(stepId)) {
        pauseStepTimer(stepId);
      } else {
        startStepTimer(stepId);
      }
      return;
    }

    notifyListeners();
  }

  void toggleGlobalCookTimerFromBottom() {
    _isGlobalTimerSelected = true;
    _pauseAllStepTimers(clearActiveSelection: false);
    notifyListeners();
  }

  void resetStepTimer(int stepId) {
    pauseStepTimer(stepId);
    RecipeStep? step;
    for (final item in _steps) {
      if (item.id == stepId) {
        step = item;
        break;
      }
    }
    if (step == null) return;
    final timerMinutes = step.timerMinutes ?? 0;
    if (timerMinutes <= 0) {
      _stepTimerSeconds.remove(stepId);
      _stepTimerInitialSeconds.remove(stepId);
      _stepTimerRunning.remove(stepId);
      if (_activeStepTimerId == stepId) {
        _activeStepTimerId = null;
      }
      notifyListeners();
      return;
    }

    _stepTimerSeconds[stepId] = timerMinutes * 60;
    _stepTimerInitialSeconds[stepId] = timerMinutes * 60;
    _stepTimerRunning[stepId] = false;
    _activeStepTimerId = stepId;
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
    if (isStepCrudLocked) return;
    try {
      await _stepRepo.create(step);
      _steps = await _stepRepo.getByDish(_dish!.id!);
      _recalcCookTimer();
      _syncStepTimersWithSteps();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStep(RecipeStep step) async {
    if (isStepCrudLocked) return;
    try {
      await _stepRepo.update(step);
      _steps = await _stepRepo.getByDish(_dish!.id!);
      _recalcCookTimer();
      _syncStepTimersWithSteps();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteStep(int id) async {
    if (isStepCrudLocked) return;
    try {
      await _stepRepo.delete(id);
      _steps.removeWhere((s) => s.id == id);
      if (_activeStepTimerId == id) {
        _activeStepTimerId = null;
      }
      _stepTimers[id]?.cancel();
      _stepTimers.remove(id);
      _stepTimerSeconds.remove(id);
      _stepTimerInitialSeconds.remove(id);
      _stepTimerRunning.remove(id);
      _recalcCookTimer();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _recalcCookTimer() {
    _cookTimerSeconds = _totalInitialCookSeconds();
  }

  int _totalInitialCookSeconds() {
    final totalMinutes = _steps.fold<int>(0, (sum, s) => sum + (s.timerMinutes ?? 0));
    return totalMinutes * 60;
  }


  void _resetAllStepTimersToInitial() {
    for (final step in _steps) {
      final stepId = step.id;
      final timerMinutes = step.timerMinutes ?? 0;
      if (stepId == null || timerMinutes <= 0) continue;

      _stepTimerSeconds[stepId] = timerMinutes * 60;
      _stepTimerInitialSeconds[stepId] = timerMinutes * 60;
      _stepTimerRunning[stepId] = false;
      _stepTimers[stepId]?.cancel();
      _stepTimers[stepId] = null;
    }
  }

  void _pauseAllStepTimers({bool clearActiveSelection = false}) {
    for (final stepId in _stepTimers.keys.toList()) {
      _stepTimers[stepId]?.cancel();
      _stepTimers[stepId] = null;
    }
    for (final key in _stepTimerRunning.keys.toList()) {
      _stepTimerRunning[key] = false;
    }
    if (clearActiveSelection) {
      _activeStepTimerId = null;
    }
  }

  void _clearStepTimersState() {
    _pauseAllStepTimers(clearActiveSelection: true);
    _stepTimers.clear();
    _stepTimerSeconds.clear();
    _stepTimerInitialSeconds.clear();
    _stepTimerRunning.clear();
  }

  void _syncStepTimersWithSteps() {
    final validIds = <int>{};
    for (final step in _steps) {
      final id = step.id;
      final timerMinutes = step.timerMinutes ?? 0;
      if (id == null || timerMinutes <= 0) continue;
      validIds.add(id);

      final initialSeconds = timerMinutes * 60;
      final previousInitial = _stepTimerInitialSeconds[id];

      if (previousInitial != null && previousInitial != initialSeconds) {
        // Timer value was edited: refresh remaining immediately to the new value.
        _stepTimers[id]?.cancel();
        _stepTimers[id] = null;
        _stepTimerRunning[id] = false;
        _stepTimerSeconds[id] = initialSeconds;
      } else {
        _stepTimerSeconds[id] = _stepTimerSeconds[id] ?? initialSeconds;
        _stepTimerRunning[id] = _stepTimerRunning[id] ?? false;
      }

      _stepTimerInitialSeconds[id] = initialSeconds;
    }

    for (final oldId in _stepTimerSeconds.keys.toList()) {
      if (validIds.contains(oldId)) continue;
      _stepTimers[oldId]?.cancel();
      _stepTimers.remove(oldId);
      _stepTimerSeconds.remove(oldId);
      _stepTimerInitialSeconds.remove(oldId);
      _stepTimerRunning.remove(oldId);
      if (_activeStepTimerId == oldId) {
        _activeStepTimerId = null;
      }
    }
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

import 'package:get_it/get_it.dart';
import 'implementations/local/app_database.dart';
import 'implementations/repositories/local_category_repository.dart';
import 'implementations/repositories/local_dish_repository.dart';
import 'implementations/repositories/local_family_secret_repository.dart';
import 'implementations/repositories/local_recipe_ingredient_repository.dart';
import 'implementations/repositories/local_recipe_step_repository.dart';
import 'implementations/repositories/local_shopping_item_repository.dart';
import 'interfaces/repositories/i_category_repository.dart';
import 'interfaces/repositories/i_dish_repository.dart';
import 'interfaces/repositories/i_family_secret_repository.dart';
import 'interfaces/repositories/i_recipe_ingredient_repository.dart';
import 'interfaces/repositories/i_recipe_step_repository.dart';
import 'interfaces/repositories/i_shopping_item_repository.dart';
import 'viewmodels/home/home_view_model.dart';
import 'viewmodels/recipe_details/recipe_details_view_model.dart';
import 'viewmodels/shopping_list/shopping_list_view_model.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  // Repositories — Home
  getIt.registerLazySingleton<ICategoryRepository>(
    () => LocalCategoryRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IDishRepository>(
    () => LocalDishRepository(getIt<AppDatabase>()),
  );

  // Repositories — Recipe Details
  getIt.registerLazySingleton<IRecipeIngredientRepository>(
    () => LocalRecipeIngredientRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IRecipeStepRepository>(
    () => LocalRecipeStepRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IFamilySecretRepository>(
    () => LocalFamilySecretRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IShoppingItemRepository>(
    () => LocalShoppingItemRepository(getIt<AppDatabase>()),
  );

  // ViewModels
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(
      categoryRepo: getIt<ICategoryRepository>(),
      dishRepo: getIt<IDishRepository>(),
    ),
  );
  getIt.registerFactory<RecipeDetailsViewModel>(
    () => RecipeDetailsViewModel(
      dishRepo: getIt<IDishRepository>(),
      ingredientRepo: getIt<IRecipeIngredientRepository>(),
      stepRepo: getIt<IRecipeStepRepository>(),
      secretRepo: getIt<IFamilySecretRepository>(),
    ),
  );
  getIt.registerFactory<ShoppingListViewModel>(
    () => ShoppingListViewModel(
      shoppingRepo: getIt<IShoppingItemRepository>(),
      dishRepo: getIt<IDishRepository>(),
      ingredientRepo: getIt<IRecipeIngredientRepository>(),
    ),
  );
}

import 'package:get_it/get_it.dart';
import 'implementations/local/app_database.dart';
import 'implementations/repositories/local_category_repository.dart';
import 'implementations/repositories/local_dish_repository.dart';
import 'interfaces/repositories/i_category_repository.dart';
import 'interfaces/repositories/i_dish_repository.dart';
import 'viewmodels/home/home_view_model.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  // Repositories
  getIt.registerLazySingleton<ICategoryRepository>(
    () => LocalCategoryRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IDishRepository>(
    () => LocalDishRepository(getIt<AppDatabase>()),
  );

  // ViewModels
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(
      categoryRepo: getIt<ICategoryRepository>(),
      dishRepo: getIt<IDishRepository>(),
    ),
  );
}

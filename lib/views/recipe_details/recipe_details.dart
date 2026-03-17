import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../di.dart';
import '../../domain/entities/dish.dart';
import '../../viewmodels/recipe_details/recipe_details_view_model.dart';
import 'widgets/family_secret_form.dart';
import 'widgets/ingredients_list.dart';
import 'widgets/recipe_info_header.dart';
import 'widgets/recipe_steps_list.dart';

class RecipeDetailsPage extends StatelessWidget {
  const RecipeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we are in a standalone route (pushed via Navigator) or embedded in MainScreen
    final routeSettings = ModalRoute.of(context)?.settings;
    final isStandalone = routeSettings?.name == '/recipe_details';
    final dishArg = routeSettings?.arguments as Dish?;

    if (isStandalone) {
      // Standalone mode: Create our own provider (Old Logic)
      return ChangeNotifierProvider<RecipeDetailsViewModel>(
        create: (_) {
          final vm = getIt<RecipeDetailsViewModel>();
          if (dishArg != null && dishArg.id != null) {
            vm.loadByDish(dishArg);
          }
          return vm;
        },
        child: const _RecipeDetailsContent(), 
      );
    }
    
    // Embedded mode: Use shared provider from MainScreen (New Logic)
    return const _RecipeDetailsContent();
  }
}

class _RecipeDetailsContent extends StatelessWidget {
  const _RecipeDetailsContent();

  @override
  Widget build(BuildContext context) {
    return const _RecipeDetailsBody();
  }
}

class _RecipeDetailsBody extends StatelessWidget {
  const _RecipeDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Consumer<RecipeDetailsViewModel>(
        builder: (context, vm, _) {
          final dish = vm.dish; // Lấy dish từ ViewModel làm source of truth
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RecipeInfoHeader(dish: dish),
                    if (dish == null)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(
                          child: EmptyDishPrompt(),
                        ),
                      )
                    else if (vm.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F))),
                      )
                    else ...[
                      if (vm.isCookTimerRunning || vm.cookTimerSeconds > 0)
                        CookTimerBanner(vm: vm),
                      IngredientsList(vm: vm, dish: dish),
                      RecipeStepsList(vm: vm, dish: dish),
                      FamilySecretForm(vm: vm, dish: dish),
                    ],
                  ],
                ),
              ),
              RecipeBottomBar(vm: vm, dish: dish),
            ],
          );
        },
      ),
    );
  }
}

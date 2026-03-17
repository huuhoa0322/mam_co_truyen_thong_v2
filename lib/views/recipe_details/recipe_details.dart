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
    final dish = ModalRoute.of(context)?.settings.arguments as Dish?;

    return ChangeNotifierProvider<RecipeDetailsViewModel>(
      create: (_) {
        final vm = getIt<RecipeDetailsViewModel>();
        if (dish != null && dish.id != null) {
          vm.loadByDish(dish);
        }
        return vm;
      },
      child: _RecipeDetailsBody(dish: dish),
    );
  }
}

class _RecipeDetailsBody extends StatelessWidget {
  final Dish? dish;
  const _RecipeDetailsBody({this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Consumer<RecipeDetailsViewModel>(
        builder: (context, vm, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RecipeInfoHeader(dish: dish),
                    if (dish == null)
                      const EmptyDishPrompt()
                    else if (vm.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F))),
                      )
                    else ...[
                      if (vm.isCookTimerRunning || vm.cookTimerSeconds > 0)
                        CookTimerBanner(vm: vm),
                      IngredientsList(vm: vm, dish: dish!),
                      RecipeStepsList(vm: vm, dish: dish!),
                      FamilySecretForm(vm: vm, dish: dish!),
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

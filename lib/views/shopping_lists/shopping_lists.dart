import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/shopping_item.dart';
import '../../viewmodels/shopping_list/shopping_list_view_model.dart';
import 'widgets/budget_header.dart';
import 'widgets/dish_selector.dart';
import 'widgets/shopping_item_form.dart';
import 'widgets/shopping_items_list.dart';

class ShoppingListsPage extends StatefulWidget {
  const ShoppingListsPage({super.key});

  @override
  State<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends State<ShoppingListsPage> {
  static const Color primary = Color(0xFFD32F2F);
  static const Color backgroundLight = Color(0xFFFFF8E7);
  static const Color surfaceLight = Color(0xFFFFFCF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Consumer<ShoppingListViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.availableDishes.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: primary));
          }

          return Column(
            children: [
              _buildAppBar(),
              if (vm.selectedDish != null)
                _buildHeader(vm),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      if (vm.selectedDish == null)
                        DishSelector(
                          availableDishes: vm.availableDishes,
                          selectedDish: vm.selectedDish,
                          onSelect: (Dish dish) {
                            vm.selectDish(dish);
                          },
                        )
                      else
                        ShoppingItemsList(
                          items: vm.items,
                          onCheckChanged: (item, val) => vm.toggleItemCheck(item, val),
                          onDelete: (item) => vm.deleteShoppingItem(item),
                          onEdit: (item) => _showItemForm(context, vm, item),
                          onEstimatePerItemAI: vm.suggestEstimatedPricePerItem,
                          isEstimatingAI: vm.isEstimatingBudget,
                          onAdd: () => _showItemForm(context, vm, null),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                final vm = context.read<ShoppingListViewModel>();
                if (vm.selectedDish != null) {
                  vm.unselectDish();
                } else {
                  // Pop if we are not at root tab navigation
                  // But since it's a tab, we probably just unselect
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  context.watch<ShoppingListViewModel>().selectedDish != null 
                    ? Icons.arrow_back 
                    : Icons.shopping_basket, 
                  color: primary
                ),
              ),
            ),
            const Text(
              'Danh Sách Đi Chợ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(width: 40), // Balance the row
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ShoppingListViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceLight.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFFEE2E2))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Món ăn: ${vm.selectedDish!.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () => vm.unselectDish(),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Đổi món'),
              )
            ],
          ),
          const SizedBox(height: 8),
          BudgetHeader(
            totalEstimatedBudget: vm.totalEstimatedBudget,
            totalActualSpent: vm.totalActualSpent,
            hasItems: vm.items.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Future<void> _showItemForm(BuildContext context, ShoppingListViewModel vm, ShoppingItem? item) async {
    if (vm.selectedDish == null) return;
    
    final result = await showDialog<ShoppingItem>(
      context: context,
      builder: (ctx) => ShoppingItemForm(
        initialItem: item,
        selectedDish: vm.selectedDish!,
      ),
    );

    if (result != null) {
      if (item == null) {
        await vm.addShoppingItem(result);
      } else {
        await vm.updateShoppingItem(result);
      }
    }
  }
}

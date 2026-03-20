import 'package:flutter/material.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/entities/recipe_ingredient.dart';
import '../../../viewmodels/recipe_details/recipe_details_view_model.dart';

const Color _primary = Color(0xFFD32F2F);
const Color _secondary = Color(0xFFFFC107);

class IngredientsList extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish dish;
  const IngredientsList({super.key, required this.vm, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.eco_outlined, color: _secondary, size: 22),
                SizedBox(width: 8),
                Text('Nguyên liệu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primary)),
              ]),
              Row(children: [
                Text('${vm.ingredients.length} loại', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.add_circle, color: _primary), onPressed: () => _showAddDialog(context)),
              ]),
            ],
          ),
          if (vm.ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Chưa có nguyên liệu. Bấm + để thêm.', style: TextStyle(color: Colors.grey.shade400))),
            )
          else
            ...vm.ingredients.map((item) => _IngredientTile(item: item, vm: vm)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Nguyên liệu'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên nguyên liệu *')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng *')),
            TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Đơn vị (g, ml, quả...) *')),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Ghi chú')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty && unitCtrl.text.isNotEmpty) {
                vm.addIngredient(RecipeIngredient(
                  dishId: dish.id!,
                  name: nameCtrl.text,
                  amount: double.tryParse(amountCtrl.text) ?? 0,
                  unit: unitCtrl.text,
                  notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final RecipeIngredient item;
  final RecipeDetailsViewModel vm;
  const _IngredientTile({required this.item, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Tap left side to toggle checked
            GestureDetector(
              onTap: () => vm.toggleIngredientChecked(item),
              behavior: HitTestBehavior.opaque,
              child: Container(width: 4, color: _secondary),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => vm.toggleIngredientChecked(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    SizedBox(
                      width: 22, height: 22,
                      child: Checkbox(
                        value: item.isChecked,
                        onChanged: (_) => vm.toggleIngredientChecked(item),
                        activeColor: _primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              color: item.isChecked ? Colors.grey.shade400 : Colors.grey.shade700,
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              fontSize: 15,
                            ),
                          ),
                          if (item.notes != null && item.notes!.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(item.notes!, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                            ),
                        ],
                      ),
                    ),
                    Text('${item.amount % 1 == 0 ? item.amount.toInt() : item.amount} ${item.unit}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
            // Action buttons column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => _showEditDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Icon(Icons.edit_outlined, size: 17, color: Colors.grey.shade500),
                  ),
                ),
                Container(height: 1, width: 28, color: Colors.grey.shade100),
                InkWell(
                  onTap: () => vm.deleteIngredient(item.id!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Icon(Icons.delete_outline, size: 17, color: Colors.redAccent.shade100),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }


  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: item.name);
    final amountCtrl = TextEditingController(text: '${item.amount % 1 == 0 ? item.amount.toInt() : item.amount}');
    final unitCtrl = TextEditingController(text: item.unit);
    final notesCtrl = TextEditingController(text: item.notes ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa Nguyên liệu'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên nguyên liệu')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng')),
            TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Đơn vị')),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Ghi chú')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              vm.updateIngredient(item.copyWith(
                name: nameCtrl.text,
                amount: double.tryParse(amountCtrl.text) ?? item.amount,
                unit: unitCtrl.text,
                notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

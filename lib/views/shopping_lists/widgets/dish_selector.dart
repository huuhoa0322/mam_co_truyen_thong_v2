import 'package:flutter/material.dart';
import '../../../../domain/entities/dish.dart';

class DishSelector extends StatelessWidget {
  final List<Dish> availableDishes;
  final Dish? selectedDish;
  final Function(Dish) onSelect;

  const DishSelector({
    super.key,
    required this.availableDishes,
    this.selectedDish,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (availableDishes.isEmpty) {
      return const Center(child: Text('Chưa có món ăn nào trong hệ thống.'));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_basket_outlined, size: 64, color: Color(0xFFFCA5A5)),
          const SizedBox(height: 16),
          const Text(
            'Hãy chọn món ăn để đi chợ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Danh sách nguyên liệu sẽ được tự động tạo dựa trên món ăn đựợc chọn.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<Dish>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelText: 'Chọn Món Ăn',
              prefixIcon: const Icon(Icons.restaurant_menu),
            ),
            value: selectedDish,
            items: availableDishes.map((dish) {
              return DropdownMenuItem<Dish>(
                value: dish,
                child: Text(dish.name),
              );
            }).toList(),
            onChanged: (dish) {
              if (dish != null) {
                onSelect(dish);
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/dish.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home/home_view_model.dart';

const _tetGold = Color(0xFFFFD700);
const _tetCream = Color(0xFFFFFDD0);

class FeaturedDishesWidget extends StatefulWidget {
  final List<Dish> dishes;
  
  const FeaturedDishesWidget({super.key, required this.dishes});

  @override
  State<FeaturedDishesWidget> createState() => _FeaturedDishesWidgetState();
}

class _FeaturedDishesWidgetState extends State<FeaturedDishesWidget> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    if (widget.dishes.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.restaurant, color: _tetGold, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Gợi Ý Món Ngon',
                  style: TextStyle(
                    color: _tetGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Hero cards List
          SizedBox(
            height: 320,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: widget.dishes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final dish = widget.dishes[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width - 48,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/recipe_details', arguments: dish);
                    },
                    onLongPress: () => _showDishOptionsDialog(context, dish),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _tetGold.withValues(alpha: 0.5), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 16)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background image
                            dish.imageUrl != null && !dish.imageUrl!.startsWith('http')
                                ? Image.file(
                                    File(dish.imageUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.red[800]),
                                  )
                                : Image.network(
                                    dish.imageUrl ?? 'https://cdn-icons-png.flaticon.com/512/3565/3565418.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(color: Colors.red[800]),
                                  ),
                            // Gradient overlay
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.90),
                                    Colors.black.withValues(alpha: 0.40),
                                    Colors.transparent,
                                  ],
                                  stops: const [0, 0.45, 1],
                                ),
                              ),
                            ),
                            // "Nổi bật" badge — top right
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red[900]?.withValues(alpha: 0.90),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: _tetGold, width: 1),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black38, blurRadius: 8)
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_fire_department, color: _tetGold, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Nổi bật',
                                      style: TextStyle(color: _tetGold, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Bottom content
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      dish.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Meta row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            _metaChip(Icons.schedule, '${dish.cookTimeMinutes} phút'),
                                            const SizedBox(width: 16),
                                            _metaChip(Icons.bar_chart, dish.difficulty),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: _tetGold.withValues(alpha: 0.3)),
                                            ),
                                            child: Icon(
                                              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                              color: _tetGold,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: _tetCream.withValues(alpha: 0.9), size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: _tetCream.withValues(alpha: 0.9), fontSize: 13),
        ),
      ],
    );
  }

  void _showDishOptionsDialog(BuildContext context, Dish dish) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dish.name),
        content: const Text('Tùy chọn cho món ăn nổi bật:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditDishDialog(context, dish);
            },
            child: const Text('Sửa'),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeViewModel>().deleteDish(dish.id!);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showEditDishDialog(BuildContext context, Dish dish) {
    final categories = context.read<HomeViewModel>().categories;
    final nameController = TextEditingController(text: dish.name);
    final descController = TextEditingController(text: dish.description ?? '');
    final timeController = TextEditingController(text: dish.cookTimeMinutes.toString());
    int? selectedCategory = dish.categoryId;
    bool isFeatured = dish.isFeatured;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setState) {
          return AlertDialog(
            title: const Text('Sửa món ăn nổi bật'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món ăn (Bắt buộc)')),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                  TextField(controller: timeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thời gian (phút)')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Bộ sưu tập'),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                  SwitchListTile(
                    title: const Text('Đánh dấu Gợi ý món ngon'),
                    contentPadding: EdgeInsets.zero,
                    value: isFeatured,
                    onChanged: (val) => setState(() => isFeatured = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final updatedDish = dish.copyWith(
                      name: nameController.text,
                      description: descController.text,
                      cookTimeMinutes: int.tryParse(timeController.text) ?? dish.cookTimeMinutes,
                      categoryId: selectedCategory,
                      isFeatured: isFeatured,
                    );
                    context.read<HomeViewModel>().updateDish(updatedDish);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        }
      ),
    );
  }
}

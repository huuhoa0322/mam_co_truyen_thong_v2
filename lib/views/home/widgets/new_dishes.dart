import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../domain/entities/dish.dart';
import 'package:provider/provider.dart';
import '../../main_screen.dart'; // Import MainScreen
import '../../../viewmodels/home/home_view_model.dart';
import '../../../viewmodels/recipe_details/recipe_details_view_model.dart'; // Import RecipeDetailsViewModel

const _tetRed = Color(0xFF8B0000);
const _tetRedLight = Color(0xFFA52A2A);
const _tetGold = Color(0xFFFFD700);
const _tetGoldDim = Color(0xFFC5A000);
const _tetCream = Color(0xFFFFFDD0);
const _cardGradientStart = Color(0xFF9E1B1B);
const _cardGradientEnd = Color(0xFF800000);

class NewDishesWidget extends StatefulWidget {
  final List<Dish> dishes;
  
  const NewDishesWidget({super.key, required this.dishes});

  @override
  State<NewDishesWidget> createState() => _NewDishesWidgetState();
}

class _NewDishesWidgetState extends State<NewDishesWidget> {
  final List<bool> _likes = [false, false, false]; // Tạm thời hardcode data tĩnh

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Row(
                children: [
                  Icon(Icons.ramen_dining, color: _tetGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Món Ngon Phải Thử',
                    style: TextStyle(
                      color: _tetGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showAllDishesBottomSheet(context),
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: _tetCream.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showAddDishDialog(context),
                    child: const Icon(Icons.add_circle, color: _tetGold, size: 24),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            widget.dishes.take(3).length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDishCard(context, widget.dishes[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, Dish dish, int index) {
    if (_likes.length <= index) {
      _likes.add(false); // dynamically add like statuses 
    }
    
    // Convert difficulty
    Color difficultyColor = _tetGold;
    Color difficultyBg = const Color(0x1AFFD700);
    if (dish.difficulty == 'Trung bình') {
      difficultyColor = const Color(0xFFFDA47A);
      difficultyBg = const Color(0x1AFB923C);
    } else if (dish.difficulty == 'Khó') {
      difficultyColor = Colors.redAccent;
      difficultyBg = const Color(0x1AFF0000);
    }

    return GestureDetector(
      onTap: () {
        context.read<RecipeDetailsViewModel>().loadByDish(dish);
        MainScreen.switchTab(context, 1);
      },
      onLongPress: () => _showDishOptionsDialog(context, dish),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_cardGradientStart, _cardGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _tetGoldDim, width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  border: Border.all(color: _tetGold.withValues(alpha: 0.3), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: dish.imageUrl != null && !dish.imageUrl!.startsWith('http')
                  ? Image.file(
                      File(dish.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: _tetRedLight),
                    )
                  : Image.network(
                      dish.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: _tetRedLight),
                    ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dish.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _likes[index] = !_likes[index]),
                        child: Icon(
                          _likes[index] ? Icons.favorite : Icons.favorite_border,
                          color: _likes[index] ? Colors.redAccent : _tetGold.withValues(alpha: 0.6),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _tetCream.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: difficultyBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: difficultyColor.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Text(
                          dish.difficulty,
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.timer_outlined,
                          color: _tetCream.withValues(alpha: 0.6), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${dish.cookTimeMinutes}p',
                        style: TextStyle(color: _tetCream.withValues(alpha: 0.6), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDishOptionsDialog(BuildContext context, Dish dish) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dish.name),
        content: const Text('Tùy chọn cho món ăn này:'),
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
    String? selectedDifficulty = dish.difficulty;
    String? currentImageUrl = dish.imageUrl;
    
    Future<void> pickImage(StateSetter setState) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Create an assets/images folder string (we'll simulate it for local dev)
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/assets/images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
        final savedFile = await File(pickedFile.path).copy('${imagesDir.path}/$fileName');
        
        setState(() {
          currentImageUrl = savedFile.path;
        });
      }
    }

    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setState) {
          return AlertDialog(
            title: const Text('Sửa món ăn'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món ăn (Bắt buộc)')),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                  TextField(controller: timeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thời gian (phút)')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: ['Dễ', 'Trung bình', 'Khó'].contains(selectedDifficulty) ? selectedDifficulty : 'Dễ',
                    decoration: const InputDecoration(labelText: 'Độ khó'),
                    items: ['Dễ', 'Trung bình', 'Khó'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => selectedDifficulty = val),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Bộ sưu tập'),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => pickImage(setState), 
                        icon: const Icon(Icons.image), 
                        label: const Text('Chọn ảnh mới')
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentImageUrl != null 
                              ? (currentImageUrl!.startsWith('http') ? 'Ảnh trên mạng' : 'Đã chọn ảnh cục bộ') 
                              : 'Chưa có ảnh',
                          style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                        ),
                      )
                    ],
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
                      difficulty: selectedDifficulty ?? 'Trung bình',
                      categoryId: selectedCategory,
                      isFeatured: isFeatured,
                      imageUrl: currentImageUrl,
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

  void _showAddDishDialog(BuildContext context) {
    final categories = context.read<HomeViewModel>().categories;
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final timeController = TextEditingController(text: '30');
    
    int? selectedCategory = categories.isNotEmpty ? categories.first.id : null;
    bool isFeatured = false;
    String selectedDifficulty = 'Trung bình';
    String? currentImageUrl;

    Future<void> pickImage(StateSetter setState) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/assets/images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
        final savedFile = await File(pickedFile.path).copy('${imagesDir.path}/$fileName');
        
        setState(() {
          currentImageUrl = savedFile.path;
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setState) {
          return AlertDialog(
            title: const Text('Thêm món ăn mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món ăn (Bắt buộc)')),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                  TextField(controller: timeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thời gian (phút)')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    decoration: const InputDecoration(labelText: 'Độ khó'),
                    items: ['Dễ', 'Trung bình', 'Khó'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => selectedDifficulty = val ?? 'Trung bình'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Bộ sưu tập'),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => pickImage(setState), 
                        icon: const Icon(Icons.image), 
                        label: const Text('Chọn ảnh mới')
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentImageUrl != null ? 'Đã chọn ảnh cục bộ' : 'Chưa có ảnh',
                          style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                        ),
                      )
                    ],
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
                    final newDish = Dish(
                      categoryId: selectedCategory,
                      name: nameController.text,
                      description: descController.text,
                      cookTimeMinutes: int.tryParse(timeController.text) ?? 30,
                      difficulty: selectedDifficulty,
                      isFeatured: isFeatured,
                      imageUrl: currentImageUrl,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    context.read<HomeViewModel>().createDish(newDish); 
                  }
                  Navigator.pop(ctx);
                }, 
                child: const Text('Thêm'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showAllDishesBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: _tetRedLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _tetCream.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tất cả Món Ngon',
                  style: TextStyle(
                    color: _tetGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: widget.dishes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final dish = widget.dishes[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        tileColor: _cardGradientStart,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: _tetGoldDim),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: dish.imageUrl != null && !dish.imageUrl!.startsWith('http')
                              ? Image.file(
                                  File(dish.imageUrl!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: _tetRed),
                                )
                              : Image.network(
                                  dish.imageUrl ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: _tetRed),
                                ),
                        ),
                        title: Text(dish.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${dish.cookTimeMinutes} phút • ${dish.difficulty}', style: TextStyle(color: _tetCream.withValues(alpha: 0.8), fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: _tetGold),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showEditDishDialog(parentContext, dish);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                Navigator.pop(ctx);
                                parentContext.read<HomeViewModel>().deleteDish(dish.id!);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          parentContext.read<RecipeDetailsViewModel>().loadByDish(dish);
                          MainScreen.switchTab(parentContext, 1);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../domain/entities/category.dart';
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

class CategoryListWidget extends StatelessWidget {
  final List<Category> categories;
  
  const CategoryListWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Bộ Sưu Tập',
                style: TextStyle(
                  color: _tetGold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _showAllCategoriesBottomSheet(context),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: _tetCream.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length + 1, // Add 1 for the Create Button
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _buildAddCategoryItem(context);
              }
              return _buildCategoryItem(context, categories[i - 1]);
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAddCategoryItem(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(context),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _tetRedLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: _tetGold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(
                Icons.add,
                color: _tetGold,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tạo mới\nBộ sưu tập',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _tetCream,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category cat) {
    return GestureDetector(
      onTap: () => _showCategoryDishesBottomSheet(context, cat),
      onLongPress: () => _showCategoryOptionsDialog(context, cat),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _tetRedLight,
                shape: BoxShape.circle,
                border: Border.all(color: _tetGold.withValues(alpha: 0.5), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6)
                ],
              ),
              child: ClipOval(
                child: cat.coverImageUrl != null && !cat.coverImageUrl!.startsWith('http')
                  ? Image.file(
                      File(cat.coverImageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported, color: Colors.white38),
                    )
                  : Image.network(
                      cat.coverImageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported, color: Colors.white38),
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cat.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tetCream,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
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
            title: const Text('Thêm Bộ sưu tập'),
            content: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tên danh mục *'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên danh mục.' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => pickImage(setState), 
                        icon: const Icon(Icons.image), 
                        label: const Text('Chọn ảnh')
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentImageUrl != null ? 'Đã chọn ảnh' : 'Chưa có ảnh',
                          style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  context.read<HomeViewModel>().createCategory(
                    nameController.text,
                    currentImageUrl ?? 'https://cdn-icons-png.flaticon.com/512/3565/3565418.png'
                  );
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

  void _showCategoryOptionsDialog(BuildContext context, Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(cat.name),
        content: const Text('Bạn muốn làm gì với danh mục này?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditCategoryDialog(context, cat);
            },
            child: const Text('Sửa'),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeViewModel>().deleteCategory(cat.id!);
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

  void _showEditCategoryDialog(BuildContext context, Category cat) {
    final nameController = TextEditingController(text: cat.name);
    final formKey = GlobalKey<FormState>();
    String? currentImageUrl = cat.coverImageUrl;
    
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
            title: const Text('Sửa Danh mục'),
            content: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tên danh mục *'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên danh mục.' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => pickImage(setState), 
                        icon: const Icon(Icons.image), 
                        label: const Text('Đổi ảnh')
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
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final updatedCategory = cat.copyWith(
                    name: nameController.text,
                    coverImageUrl: currentImageUrl ?? cat.coverImageUrl,
                  );
                  context.read<HomeViewModel>().updateCategory(updatedCategory);
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

  void _showAllCategoriesBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: _tetRed,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
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
                  'Tất cả Bộ Sưu Tập',
                  style: TextStyle(
                    color: _tetGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _tetRedLight,
                          backgroundImage: cat.coverImageUrl != null && !cat.coverImageUrl!.startsWith('http')
                              ? FileImage(File(cat.coverImageUrl!)) as ImageProvider
                              : NetworkImage(cat.coverImageUrl ?? ''),
                          onBackgroundImageError: (_, _) => const Icon(Icons.error),
                        ),
                        title: Text(cat.name, style: const TextStyle(color: _tetCream, fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: _tetCream),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showEditCategoryDialog(parentContext, cat);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                Navigator.pop(ctx);
                                parentContext.read<HomeViewModel>().deleteCategory(cat.id!);
                              },
                            ),
                          ],
                        ),
                        onTap: () => Navigator.pop(ctx),
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

  void _showCategoryDishesBottomSheet(BuildContext parentContext, Category cat) async {
    final viewModel = parentContext.read<HomeViewModel>();
    final dishes = await viewModel.getDishesByCategory(cat.id!);
    
    // ignore: use_build_context_synchronously
    if (!parentContext.mounted) return;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bộ sưu tập: ${cat.name}',
                      style: const TextStyle(
                        color: _tetGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: _tetGold),
                      onPressed: () {
                        _showAddDishInCategoryDialog(parentContext, cat);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (dishes.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('Chưa có món ăn nào trong bộ sưu tập này.', style: TextStyle(color: _tetCream)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: dishes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          tileColor: Colors.black12,
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
                                  errorBuilder: (_, _, _) => Container(width: 60, height: 60, color: _tetRed),
                                )
                              : Image.network(
                                  dish.imageUrl ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(width: 60, height: 60, color: _tetRed),
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
                                  // Can trigger showEditDishDialog here if we extract it outside, or just delegate 
                                  // For simplicity we show a toast or implement edit dialog if needed
                                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Vui lòng sửa ở mục Món Ngon Phải Thử')));
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

  void _showAddDishInCategoryDialog(BuildContext context, Category cat) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final timeController = TextEditingController(text: '30');
    final servingsMinController = TextEditingController(text: '2');
    final servingsMaxController = TextEditingController(text: '4');
    final formKey = GlobalKey<FormState>();
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
            title: Text('Thêm món vào ${cat.name}'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tên món ăn *'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên món ăn.' : null,
                  ),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                  TextFormField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Thời gian (phút) *'),
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Thời gian phải là số nguyên > 0.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Khẩu phần (người)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: servingsMinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Tối thiểu *'),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final parsed = int.tryParse((value ?? '').trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Giá trị > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: servingsMaxController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Tối đa *'),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final max = int.tryParse((value ?? '').trim());
                            final min = int.tryParse(servingsMinController.text.trim());
                            if (max == null || max <= 0) {
                              return 'Giá trị > 0';
                            }
                            if (min == null || min <= 0) {
                              return 'Kiểm tra tối thiểu';
                            }
                            if (max <= min) {
                              return 'Phải lớn hơn tối thiểu';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDifficulty,
                    decoration: const InputDecoration(labelText: 'Độ khó'),
                    items: ['Dễ', 'Trung bình', 'Khó'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => selectedDifficulty = val ?? 'Trung bình'),
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
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }

                  final servingsMin = int.tryParse(servingsMinController.text.trim());
                  final servingsMax = int.tryParse(servingsMaxController.text.trim());
                  if (servingsMin == null || servingsMax == null) {
                    return;
                  }

                  final newDish = Dish(
                    categoryId: cat.id,
                    name: nameController.text,
                    description: descController.text,
                    cookTimeMinutes: int.tryParse(timeController.text) ?? 30,
                    difficulty: selectedDifficulty,
                    servingsMin: servingsMin,
                    servingsMax: servingsMax,
                    isFeatured: isFeatured,
                    imageUrl: currentImageUrl,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context.read<HomeViewModel>().createDish(newDish);
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
}

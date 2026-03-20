import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/family_secret.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/entities/category.dart';
import '../../../viewmodels/family_secret/secret_view_model.dart';
import '../family_secret.dart';

class CreateSecretModal extends StatefulWidget {
  final FamilySecret? initialSecret;

  const CreateSecretModal({super.key, this.initialSecret});

  @override
  State<CreateSecretModal> createState() => _CreateSecretModalState();
}

class _CreateSecretModalState extends State<CreateSecretModal> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  
  // For new dish
  bool _isCreatingNewDish = false;
  late TextEditingController _newDishNameController;
  Category? _selectedNewDishCategory;
  
  // For existing dish
  Dish? _selectedDish;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialSecret?.title ?? '');
    _contentController = TextEditingController(text: widget.initialSecret?.content ?? '');
    _tagsController = TextEditingController(text: widget.initialSecret?.tags.join(', ') ?? '');
    _newDishNameController = TextEditingController();

    // If editing, we need to find the Dish that this secret belongs to
    // But we need to do this after context is ready, or use Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSecret != null) {
        final vm = context.read<SecretViewModel>();
        setState(() {
          _selectedDish = vm.getDishForSecret(widget.initialSecret!);
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _newDishNameController.dispose();
    super.dispose();
  }

  void _submit(SecretViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate custom logic
    if (widget.initialSecret == null) {
      if (!_isCreatingNewDish && _selectedDish == null) {
        _showError('Vui lòng chọn hoặc tạo mới món ăn.');
        return;
      }
      if (_isCreatingNewDish) {
        if (_newDishNameController.text.trim().isEmpty) {
          _showError('Tên món mới không được để trống.');
          return;
        }
        if (_selectedNewDishCategory == null) {
          _showError('Vui lòng chọn Bộ sưu tập cho món mới.');
          return;
        }
      }
    }

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (widget.initialSecret == null) {
      // Create new
      await vm.addSecret(
        existingDish: _isCreatingNewDish ? null : _selectedDish,
        newDishName: _isCreatingNewDish ? _newDishNameController.text.trim() : null,
        newDishCategoryId: _isCreatingNewDish ? _selectedNewDishCategory?.id : null,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tags,
      );
    } else {
      // Update existing
      final updated = widget.initialSecret!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tags,
      );
      await vm.updateSecret(updated);
    }

    if (mounted) {
      if (vm.errorMessage != null) {
        _showError(vm.errorMessage!);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu bí kíp thành công!')),
        );
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SecretViewModel>();
    final isEditing = widget.initialSecret != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: FamilySecretPage.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Sửa Bí Kíp' : 'Ghi Bí Kíp Mới',
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: FamilySecretPage.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dish Selection
                    if (isEditing)
                      _buildHeaderLabel('Món ăn: ${_selectedDish?.name ?? 'Không rõ'}')
                    else
                      _buildDishSelector(vm),

                    const SizedBox(height: 20),
                    
                    _buildTextField(
                      controller: _titleController,
                      label: 'Tên gọi bí kíp (Tùy chọn)',
                      hint: 'VD: Nước mắm chua ngọt chuẩn vị',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _contentController,
                      label: 'Nội dung bí kíp *',
                      hint: 'Mô tả chi tiết định lượng, lửa, cách nêm...',
                      maxLines: 4,
                      validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập nội dung.' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _tagsController,
                      label: 'Thẻ đánh dấu (Tags)',
                      hint: 'VD: ngày tết, mặn, không cay (cách nhau bởi dấu phẩy)',
                    ),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FamilySecretPage.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: vm.isLoading ? null : () => _submit(vm),
                        child: vm.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                            : const Text('LƯU BÍ KÍP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDishSelector(SecretViewModel vm) {
    if (_isCreatingNewDish) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tạo Món Mới', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _isCreatingNewDish = false),
                child: const Text('Chọn món có sẵn', style: TextStyle(color: FamilySecretPage.primary)),
              ),
            ],
          ),
          _buildTextField(
            controller: _newDishNameController,
            label: 'Tên món ăn mới *',
            hint: 'VD: Thịt kho hột vịt',
          ),
          const SizedBox(height: 12),
          const Text('Chọn Bộ sưu tập *', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          DropdownButtonFormField<Category>(
            decoration: _inputDecoration(),
            initialValue: _selectedNewDishCategory,
            items: vm.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
            onChanged: (val) => setState(() => _selectedNewDishCategory = val),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Chọn Món Ăn', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => setState(() => _isCreatingNewDish = true),
              child: const Text('+ Tạo món mới', style: TextStyle(color: FamilySecretPage.primary)),
            ),
          ],
        ),
        DropdownButtonFormField<Dish>(
          decoration: _inputDecoration().copyWith(hintText: 'Chọn món trong danh sách...'),
          initialValue: _selectedDish,
          items: vm.availableDishes.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
          onChanged: (val) => setState(() => _selectedDish = val),
        ),
      ],
    );
  }

  Widget _buildHeaderLabel(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: FamilySecretPage.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: FamilySecretPage.primary)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: _inputDecoration().copyWith(hintText: hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FamilySecretPage.primary),
      ),
    );
  }
}

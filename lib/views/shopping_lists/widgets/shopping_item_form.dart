import 'package:flutter/material.dart';
import '../../../../domain/entities/dish.dart';
import '../../../../domain/entities/shopping_item.dart';

class ShoppingItemForm extends StatefulWidget {
  final ShoppingItem? initialItem;
  final Dish selectedDish;

  const ShoppingItemForm({
    super.key,
    this.initialItem,
    required this.selectedDish,
  });

  @override
  State<ShoppingItemForm> createState() => _ShoppingItemFormState();
}

class _ShoppingItemFormState extends State<ShoppingItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _estPriceCtrl;
  late TextEditingController _actPriceCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameCtrl = TextEditingController(text: item?.ingredientName ?? '');
    _amountCtrl = TextEditingController(text: item != null ? item.quantity.toString() : '1');
    _unitCtrl = TextEditingController(text: item?.unit ?? 'cái');
    _estPriceCtrl = TextEditingController(text: item != null ? item.estimatedPrice.toString() : '');
    _actPriceCtrl = TextEditingController(text: item?.actualPrice?.toString() ?? '');
    _notesCtrl = TextEditingController(text: item?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _unitCtrl.dispose();
    _estPriceCtrl.dispose();
    _actPriceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialItem == null ? 'Thêm nguyên liệu' : 'Sửa nguyên liệu'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên nguyên liệu (*)'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Không được để trống' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Nhập số lượng';
                        if (double.tryParse(val) == null) return 'Phải là số';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitCtrl,
                      decoration: const InputDecoration(labelText: 'Đơn vị'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Bắt buộc' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _estPriceCtrl,
                decoration: const InputDecoration(labelText: 'Giá dự kiến (VND) (*)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Bắt buộc';
                  if (int.tryParse(val) == null) return 'Phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _actPriceCtrl,
                decoration: const InputDecoration(labelText: 'Giá thực chi (VND)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty && int.tryParse(val) == null) {
                    return 'Phải là số nguyên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final actPriceText = _actPriceCtrl.text.trim();
    final actualPrice = actPriceText.isNotEmpty ? int.parse(actPriceText) : null;

    final result = ShoppingItem(
      id: widget.initialItem?.id,
      dishId: widget.selectedDish.id,
      ingredientName: _nameCtrl.text.trim(),
      quantity: double.parse(_amountCtrl.text.trim()),
      unit: _unitCtrl.text.trim(),
      estimatedPrice: int.parse(_estPriceCtrl.text.trim()),
      actualPrice: actualPrice,
      isChecked: widget.initialItem?.isChecked ?? false,
      notes: _notesCtrl.text.trim(),
    );

    Navigator.pop(context, result);
  }
}

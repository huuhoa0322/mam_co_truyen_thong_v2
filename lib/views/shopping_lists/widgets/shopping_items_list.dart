import 'package:flutter/material.dart';
import '../../../../domain/entities/shopping_item.dart';

class ShoppingItemsList extends StatelessWidget {
  final List<ShoppingItem> items;
  final Function(ShoppingItem, bool) onCheckChanged;
  final Function(ShoppingItem) onEdit;
  final Function(int) onDelete;
  final VoidCallback onAdd;

  const ShoppingItemsList({
    super.key,
    required this.items,
    required this.onCheckChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFD32F2F);
    const Color surfaceLight = Color(0xFFFFFCF5);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Danh sách đi chợ trống',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Thêm nguyên liệu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Danh sách cần mua',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: primary),
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFEE2E2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFFEF2F2)),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemRow(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, ShoppingItem item) {
    const Color primary = Color(0xFFD32F2F);
    final String priceEst = _formatNumber(item.estimatedPrice);
    final String priceAct = item.actualPrice != null ? _formatNumber(item.actualPrice!) : '---';

    return InkWell(
      onTap: () => onEdit(item),
      onLongPress: () => _showDeleteConfirm(context, item),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: item.isChecked,
                onChanged: (val) {
                  if (val != null) onCheckChanged(item, val);
                },
                activeColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: item.isChecked ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ingredientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: const Color(0xFF1F2937),
                        decoration: item.isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.notes!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity.toString().replaceAll(RegExp(r'\.0$'), '')} ${item.unit}',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF374151)),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: item.isChecked ? 0.5 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Dự kiến: $priceEst',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Thực tế: $priceAct',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ShoppingItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa nguyên liệu'),
        content: Text('Bạn có chắc muốn xóa "${item.ingredientName}"? Ngân sách sẽ được cập nhật lại.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (item.id != null) {
                onDelete(item.id!);
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number == 0) return '0';
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

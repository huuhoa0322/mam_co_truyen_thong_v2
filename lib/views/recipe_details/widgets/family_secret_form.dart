import 'package:flutter/material.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/entities/family_secret.dart';
import '../../../viewmodels/recipe_details/recipe_details_view_model.dart';

const Color _primary = Color(0xFFD32F2F);
const Color _primaryDark = Color(0xFFB71C1C);
const Color _secondary = Color(0xFFFFC107);

class FamilySecretForm extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish dish;
  const FamilySecretForm({super.key, required this.vm, required this.dish});

  @override
  Widget build(BuildContext context) {
    final secret = vm.familySecret;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA), width: 2),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -8, bottom: -8,
              child: Transform.rotate(angle: 0.2, child: Icon(Icons.favorite, size: 100, color: _primary.withValues(alpha: 0.08))),
            ),
            Positioned(
              top: -16, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_primary, _primaryDark]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _secondary, width: 2),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.auto_awesome, size: 16, color: _secondary),
                    SizedBox(width: 6),
                    Text('Bí kíp gia truyền', style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
                    SizedBox(width: 6),
                    Icon(Icons.auto_awesome, size: 16, color: _secondary),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (secret != null) ...[
                    if (secret.title != null)
                      Text(secret.title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primary)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Text('"${secret.content}"',
                          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFF374151), height: 1.5)),
                    ),
                    if (secret.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: secret.tags.map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _primary.withValues(alpha: 0.2)),
                            ),
                            child: Text(t, style: const TextStyle(fontSize: 11, color: _primaryDark, fontStyle: FontStyle.italic)),
                          )).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDialog(context, secret),
                          icon: const Icon(Icons.edit_note, color: _primary),
                          label: const Text('Sửa bí kíp', style: TextStyle(color: _primary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => vm.deleteFamilySecret(),
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        label: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ]),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDialog(context, null),
                        icon: const Icon(Icons.edit_note, color: _primary),
                        label: const Text('Thêm bí kíp gia truyền', style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, FamilySecret? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final tagsCtrl = TextEditingController(text: existing?.tags.join(', ') ?? '');
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Thêm bí kíp' : 'Sửa bí kíp'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề (VD: Mẹo của Bà Nội)')),
            const SizedBox(height: 8),
            TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Nội dung bí kíp *')),
            const SizedBox(height: 8),
            if (vm.isSuggestingSecret)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: _primary)),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    // Start suggesting
                    setDialogState(() {}); // vm.isSuggestingSecret will be evaluated via vm
                    final draft = await vm.suggestSecretDraftFromAI();
                    if (draft != null) {
                      titleCtrl.text = draft.title;
                      contentCtrl.text = draft.content;
                      tagsCtrl.text = draft.tags.join(', ');
                    }
                    setDialogState(() {});
                  },
                  icon: const Icon(Icons.auto_awesome, color: _primary, size: 18),
                  label: const Text('Hỏi AI gợi ý nội dung', style: TextStyle(color: _primary)),
                ),
              ),
            const SizedBox(height: 8),
            TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: 'Thẻ tag (ngăn cách bởi dấu phẩy)')),
          ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (contentCtrl.text.isNotEmpty) {
                final tags = tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                
                vm.saveFamilySecret(FamilySecret(
                  id: existing?.id,
                  dishId: dish.id!,
                  title: titleCtrl.text.isEmpty ? null : titleCtrl.text,
                  content: contentCtrl.text,
                  tags: tags,

                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    ),
  );
}
}

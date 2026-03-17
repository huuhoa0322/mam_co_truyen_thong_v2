import 'package:flutter/material.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/entities/recipe_step.dart';
import '../../../viewmodels/recipe_details/recipe_details_view_model.dart';

const Color _primary = Color(0xFFD32F2F);
const Color _secondary = Color(0xFFFFC107);

class RecipeStepsList extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish dish;
  const RecipeStepsList({super.key, required this.vm, required this.dish});

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
                Icon(Icons.menu_book_outlined, color: _secondary, size: 22),
                SizedBox(width: 8),
                Text('Cách làm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primary)),
              ]),
              IconButton(icon: const Icon(Icons.add_circle, color: _primary), onPressed: () => _showAddDialog(context)),
            ],
          ),
          if (vm.steps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Chưa có bước làm. Bấm + để thêm.', style: TextStyle(color: Colors.grey.shade400))),
            )
          else
            ...vm.steps.asMap().entries.map((e) => _StepTile(
              step: e.value,
              isLast: e.key == vm.steps.length - 1,
              vm: vm,
              dish: dish,
            )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final timerCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Bước làm'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề bước *')),
            TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Mô tả *')),
            TextField(controller: timerCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hẹn giờ (phút, để trống nếu không cần)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                final timerMins = int.tryParse(timerCtrl.text);
                vm.addStep(RecipeStep(
                  dishId: dish.id!,
                  stepNumber: vm.steps.length + 1,
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  timerMinutes: timerMins,
                  timerLabel: timerMins != null ? 'Hẹn giờ (${timerMins}p)' : null,
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

class _StepTile extends StatelessWidget {
  final RecipeStep step;
  final bool isLast;
  final RecipeDetailsViewModel vm;
  final Dish dish;
  const _StepTile({required this.step, required this.isLast, required this.vm, required this.dish});

  @override
  Widget build(BuildContext context) {
    final hasTimer = step.timerMinutes != null && step.id != null;
    final isRunning = hasTimer && vm.isStepTimerRunning(step.id!);
    final remaining = hasTimer ? vm.stepTimerOf(step.id!) : 0;

    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(children: [
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: _primary,
                    boxShadow: [BoxShadow(color: Color(0x40D32F2F), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Center(child: Text('${step.stepNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16))),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 1.5, margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0x4DD32F2F), width: 1.5))))),
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  Text(step.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6)),
                  if (hasTimer) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      GestureDetector(
                        onTap: () => isRunning ? vm.pauseStepTimer(step.id!) : vm.startStepTimer(step.id!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFEE2E2)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(isRunning ? Icons.pause_circle : Icons.timer, size: 16, color: _primary),
                            const SizedBox(width: 6),
                            Text(
                              remaining > 0 ? vm.formatTime(remaining) : (step.timerLabel ?? ''),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary),
                            ),
                          ]),
                        ),
                      ),
                      if (isRunning || remaining < (step.timerMinutes! * 60)) ...[
                        const SizedBox(width: 8),
                        GestureDetector(onTap: () => vm.resetStepTimer(step.id!), child: const Icon(Icons.refresh, size: 18, color: Colors.grey)),
                      ],
                    ]),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit, color: _primary),
            title: const Text('Sửa'),
            onTap: () { Navigator.pop(ctx); _showEditDialog(context); },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text('Xóa'),
            onTap: () { Navigator.pop(ctx); vm.deleteStep(step.id!); },
          ),
        ]),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: step.title);
    final descCtrl = TextEditingController(text: step.description);
    final timerCtrl = TextEditingController(text: step.timerMinutes?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa Bước làm'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề bước')),
            TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Mô tả')),
            TextField(controller: timerCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hẹn giờ (phút)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final timerMins = int.tryParse(timerCtrl.text);
              vm.updateStep(step.copyWith(
                title: titleCtrl.text,
                description: descCtrl.text,
                timerMinutes: timerMins,
                timerLabel: timerMins != null ? 'Hẹn giờ (${timerMins}p)' : null,
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

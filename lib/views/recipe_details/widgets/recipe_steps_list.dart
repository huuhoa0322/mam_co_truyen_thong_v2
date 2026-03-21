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
              Row(children: [
                if (vm.isSuggestingSteps)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _primary))
                else
                  IconButton(
                    icon: const Icon(Icons.auto_awesome, color: _primary),
                    tooltip: 'Gợi ý AI',
                    onPressed: vm.isStepCrudLocked ? null : () => _handleSuggestSteps(context),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: _primary),
                  onPressed: vm.isStepCrudLocked ? null : () => _showAddDialog(context),
                ),
              ]),
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
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Thêm Bước làm'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tiêu đề bước *'),
                onChanged: (_) => setDialogState(() => errorText = null),
              ),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả *'),
                onChanged: (_) => setDialogState(() => errorText = null),
              ),
              TextField(
                controller: timerCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hẹn giờ (phút, để trống nếu không cần)'),
                onChanged: (_) => setDialogState(() => errorText = null),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        errorText!,
                        style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (vm.isStepCrudLocked) {
                  setDialogState(() => errorText = 'Đồng hồ đang chạy, không thể thêm bước làm.');
                  return;
                }
                if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                  setDialogState(() => errorText = 'Vui lòng nhập tiêu đề và mô tả bước.');
                  return;
                }

                final timerRaw = timerCtrl.text.trim();
                int? timerMins;
                if (timerRaw.isNotEmpty) {
                  timerMins = int.tryParse(timerRaw);
                  if (timerMins == null || timerMins <= 0) {
                    setDialogState(() => errorText = 'Hẹn giờ phải là số nguyên lớn hơn 0.');
                    return;
                  }
                }

                final currentTotal = vm.steps.fold<int>(0, (sum, s) => sum + (s.timerMinutes ?? 0));
                final projectedTotal = currentTotal + (timerMins ?? 0);
                if (projectedTotal > dish.cookTimeMinutes) {
                  setDialogState(
                    () => errorText =
                        'Tổng thời gian các bước ($projectedTotal phút) không được vượt quá thời gian món (${dish.cookTimeMinutes} phút).',
                  );
                  return;
                }

                vm.addStep(RecipeStep(
                  dishId: dish.id!,
                  stepNumber: vm.steps.length + 1,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  timerMinutes: timerMins,
                  timerLabel: timerMins != null ? 'Hẹn giờ (${timerMins}p)' : null,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSuggestSteps(BuildContext context) async {
    final drafts = await vm.suggestStepDraftsFromAI();
    if (drafts.isEmpty || !context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lấy gợi ý từ AI, vui lòng thử lại.')));
      }
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final selected = List.generate(drafts.length, (index) => true);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Row(children: [
                Icon(Icons.auto_awesome, color: _secondary),
                SizedBox(width: 8),
                Text('Gợi ý từ AI', style: TextStyle(fontSize: 18, color: _primary)),
              ]),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: drafts.length,
                  itemBuilder: (ctx, i) {
                    final draft = drafts[i];
                    return CheckboxListTile(
                      value: selected[i],
                      title: Text(draft.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${draft.description}${draft.timerMinutes != null ? ' (${draft.timerMinutes}p)' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      activeColor: _primary,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() => selected[i] = val ?? false);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    final currentTotal = vm.steps.fold<int>(0, (sum, s) => sum + (s.timerMinutes ?? 0));
                    final selectedTotal = drafts
                        .asMap()
                        .entries
                        .where((e) => selected[e.key])
                        .fold<int>(0, (sum, e) => sum + (e.value.timerMinutes ?? 0));
                    final projectedTotal = currentTotal + selectedTotal;
                    if (projectedTotal > dish.cookTimeMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tổng thời gian các bước ($projectedTotal phút) không được vượt quá thời gian món (${dish.cookTimeMinutes} phút).',
                          ),
                        ),
                      );
                      return;
                    }

                    int count = vm.steps.length;
                    for (int i = 0; i < drafts.length; i++) {
                      if (selected[i]) {
                        final draft = drafts[i];
                        count++;
                        final timerMins = draft.timerMinutes;
                        vm.addStep(RecipeStep(
                          dishId: dish.id!,
                          stepNumber: count,
                          title: draft.title,
                          description: draft.description,
                          timerMinutes: timerMins,
                          timerLabel: timerMins != null ? 'Hẹn giờ (${timerMins}p)' : null,
                        ));
                      }
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                  child: const Text('Thêm đã chọn'),
                ),
              ],
            );
          },
        );
      },
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
    final isCrudLocked = vm.isStepCrudLocked;
    final timerMinutesValue = step.timerMinutes ?? 0;
    final hasTimer = timerMinutesValue > 0 && step.id != null;
    final isSelected = hasTimer && vm.activeStepTimerStep?.id == step.id;
    final isRunning = hasTimer && vm.isStepTimerRunning(step.id!);
    final canTapClock = hasTimer && vm.canSelectStepTimer;
    final remaining = hasTimer ? vm.stepTimerOf(step.id!) : 0;

    return IntrinsicHeight(
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
                // Title row with edit/delete buttons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                    ),
                    Opacity(
                      opacity: isCrudLocked ? 0.45 : 1,
                      child: GestureDetector(
                        onTap: isCrudLocked ? null : () => _showEditDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Icon(Icons.edit_outlined, size: 17, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: isCrudLocked ? 0.45 : 1,
                      child: GestureDetector(
                        onTap: isCrudLocked ? null : () => vm.deleteStep(step.id!),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Icon(Icons.delete_outline, size: 17, color: Colors.redAccent.shade100),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(step.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6)),
                if (hasTimer) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Opacity(
                      opacity: canTapClock ? 1 : 0.45,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: canTapClock ? () => vm.selectStepTimer(step.id!) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFEE2E2) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? const Color(0xFFFCA5A5) : const Color(0xFFFEE2E2)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(isRunning ? Icons.timer : Icons.timer_outlined, size: 16, color: _primary),
                            const SizedBox(width: 6),
                            Text(
                              remaining > 0 ? vm.formatTime(remaining) : (step.timerLabel ?? ''),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    if (isRunning || remaining < (timerMinutesValue * 60)) ...[
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
    );
  }


  void _showEditDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: step.title);
    final descCtrl = TextEditingController(text: step.description);
    final timerCtrl = TextEditingController(text: step.timerMinutes?.toString() ?? '');
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Sửa Bước làm'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tiêu đề bước *'),
                onChanged: (_) => setDialogState(() => errorText = null),
              ),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả *'),
                onChanged: (_) => setDialogState(() => errorText = null),
              ),
              TextField(
                controller: timerCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hẹn giờ (phút, để trống nếu không cần)'),
                onChanged: (_) => setDialogState(() => errorText = null),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        errorText!,
                        style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (vm.isStepCrudLocked) {
                  setDialogState(() => errorText = 'Đồng hồ đang chạy, không thể sửa bước làm.');
                  return;
                }
                if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                  setDialogState(() => errorText = 'Vui lòng nhập tiêu đề và mô tả bước.');
                  return;
                }

                final timerRaw = timerCtrl.text.trim();
                int? timerMins;
                if (timerRaw.isNotEmpty) {
                  timerMins = int.tryParse(timerRaw);
                  if (timerMins == null || timerMins <= 0) {
                    setDialogState(() => errorText = 'Hẹn giờ phải là số nguyên lớn hơn 0.');
                    return;
                  }
                }

                final currentTotal = vm.steps.fold<int>(0, (sum, s) => sum + (s.timerMinutes ?? 0));
                final baseTotal = currentTotal - (step.timerMinutes ?? 0);
                final projectedTotal = baseTotal + (timerMins ?? 0);
                if (projectedTotal > dish.cookTimeMinutes) {
                  setDialogState(
                    () => errorText =
                        'Tổng thời gian các bước ($projectedTotal phút) không được vượt quá thời gian món (${dish.cookTimeMinutes} phút).',
                  );
                  return;
                }

                vm.updateStep(step.copyWith(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  timerMinutes: timerMins,
                  timerLabel: timerMins != null ? 'Hẹn giờ (${timerMins}p)' : null,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}

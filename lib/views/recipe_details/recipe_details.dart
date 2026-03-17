import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../di.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/family_secret.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/recipe_step.dart';
import '../../viewmodels/recipe_details/recipe_details_view_model.dart';
import '../../viewmodels/home/home_view_model.dart';

class RecipeDetailsPage extends StatelessWidget {
  const RecipeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dish = ModalRoute.of(context)?.settings.arguments as Dish?;

    return ChangeNotifierProvider<RecipeDetailsViewModel>(
      create: (_) {
        final vm = getIt<RecipeDetailsViewModel>();
        if (dish != null && dish.id != null) {
          vm.loadByDish(dish);
        }
        return vm;
      },
      child: _RecipeDetailsView(dish: dish),
    );
  }
}

class _RecipeDetailsView extends StatelessWidget {
  final Dish? dish;

  const _RecipeDetailsView({this.dish});

  static const Color primary = Color(0xFFD32F2F);
  static const Color backgroundLight = Color(0xFFFFF8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Consumer<RecipeDetailsViewModel>(
        builder: (context, vm, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroSection(dish: dish),
                    _StatsCard(dish: dish),
                    if (dish == null)
                      _EmptyDishPrompt(context: context)
                    else if (vm.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator(color: primary)),
                      )
                    else ...[
                      if (vm.isCookTimerRunning || vm.cookTimerSeconds > 0)
                        _CookTimerBanner(vm: vm),
                      _IngredientsSection(vm: vm, dish: dish!),
                      _StepsSection(vm: vm, dish: dish!),
                      _FamilySecretSection(vm: vm, dish: dish!),
                    ],
                  ],
                ),
              ),
              _BottomBar(vm: vm, dish: dish),
            ],
          );
        },
      ),
    );
  }
}

// ── Empty state when no dish selected ──────────────────────────────────────
class _EmptyDishPrompt extends StatelessWidget {
  final BuildContext context;
  const _EmptyDishPrompt({required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có món ăn được chọn',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showDishPicker(context),
            icon: const Icon(Icons.search),
            label: const Text('Chọn món ăn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDishPicker(BuildContext context) {
    final homeVm = context.read<HomeViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF8F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Chọn Món Ăn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: homeVm.recentDishes.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final d = homeVm.recentDishes[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: d.imageUrl != null && !d.imageUrl!.startsWith('http')
                          ? Image.file(File(d.imageUrl!), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: const Color(0xFFD32F2F)))
                          : Image.network(d.imageUrl ?? '', width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: const Color(0xFFD32F2F))),
                    ),
                    title: Text(d.name),
                    subtitle: Text('${d.cookTimeMinutes} phút • ${d.difficulty}'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(
                        context,
                        '/recipe_details',
                        arguments: d,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Image ──────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Dish? dish;
  const _HeroSection({this.dish});

  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color secondary = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: dish?.imageUrl != null && !dish!.imageUrl!.startsWith('http')
                ? Image.file(File(dish!.imageUrl!), fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: primaryDark, child: const Center(child: Icon(Icons.restaurant, size: 80, color: Colors.white54))))
                : Image.network(
                    dish?.imageUrl ?? 'https://cdn-icons-png.flaticon.com/512/3565/3565418.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: primaryDark, child: const Center(child: Icon(Icons.restaurant, size: 80, color: Colors.white54))),
                  ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x33000000), Color(0xCC000000)],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(Icons.arrow_back, () => Navigator.of(context).pop()),
                Row(children: [
                  _circleBtn(Icons.favorite_border, () {}),
                  const SizedBox(width: 12),
                  _circleBtn(Icons.share_outlined, () {}),
                ]),
              ],
            ),
          ),
          Positioned(
            bottom: 24, left: 24, right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dish != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('${dish!.cookTimeMinutes} phút', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  dish?.name ?? 'Chọn món ăn',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black54)]),
                ),
                if (dish?.description != null) ...[
                  const SizedBox(height: 2),
                  Text(dish!.description!, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.9))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, color: Colors.white, size: 24)),
      ),
    );
  }
}

// ── Stats Card ──────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final Dish? dish;
  const _StatsCard({this.dish});

  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Transform.translate(
        offset: const Offset(0, -24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              _stat(Icons.restaurant_menu_outlined, 'Khẩu phần', dish != null ? '${dish!.servingsMin}-${dish!.servingsMax}' : '--'),
              _div(),
              _stat(Icons.signal_cellular_alt_outlined, 'Độ khó', dish?.difficulty ?? '--'),
              _div(),
              _stat(Icons.schedule_outlined, 'Thời gian', dish != null ? '${dish!.cookTimeMinutes} phút' : '--'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) => Expanded(
    child: Column(children: [
      Icon(icon, color: primary, size: 24),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500, letterSpacing: 0.8)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827))),
    ]),
  );

  Widget _div() => Container(width: 1, height: 40, color: Colors.grey.shade200);
}

// ── Cook Timer Banner ────────────────────────────────────────────────────────
class _CookTimerBanner extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  const _CookTimerBanner({required this.vm});

  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [secondary, Color(0xFFFB923C)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x4DFFC107), blurRadius: 14, offset: Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đang nấu...', style: TextStyle(color: Color(0xFF7F1D1D), fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 2),
                Text('Đếm ngược toàn bộ', style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 13)),
              ],
            ),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                child: Text(vm.formatTime(vm.cookTimerSeconds),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D), fontFamily: 'monospace', letterSpacing: 2)),
              ),
              const SizedBox(width: 12),
              Material(
                color: primary,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => vm.isCookTimerRunning ? vm.pauseCookTimer() : vm.startCookTimer(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(vm.isCookTimerRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Ingredients Section ─────────────────────────────────────────────────────
class _IngredientsSection extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish dish;
  const _IngredientsSection({required this.vm, required this.dish});

  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);

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
                Icon(Icons.eco_outlined, color: secondary, size: 22),
                SizedBox(width: 8),
                Text('Nguyên liệu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              ]),
              Row(children: [
                Text('${vm.ingredients.length} loại', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: primary),
                  onPressed: () => _showAddIngredient(context),
                ),
              ]),
            ],
          ),
          if (vm.ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Chưa có nguyên liệu. Bấm + để thêm.', style: TextStyle(color: Colors.grey.shade400))),
            )
          else
            ...vm.ingredients.map((item) => _IngredientTile(item: item, vm: vm)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAddIngredient(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Nguyên liệu'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên nguyên liệu *')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng *')),
            TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Đơn vị (g, ml, quả...) *')),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Ghi chú')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty && unitCtrl.text.isNotEmpty) {
                vm.addIngredient(RecipeIngredient(
                  dishId: dish.id!,
                  name: nameCtrl.text,
                  amount: double.tryParse(amountCtrl.text) ?? 0,
                  unit: unitCtrl.text,
                  notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
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

class _IngredientTile extends StatelessWidget {
  final RecipeIngredient item;
  final RecipeDetailsViewModel vm;
  const _IngredientTile({required this.item, required this.vm});

  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => vm.toggleIngredientChecked(item),
        onLongPress: () => _showOptions(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: secondary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      SizedBox(
                        width: 22, height: 22,
                        child: Checkbox(
                          value: item.isChecked,
                          onChanged: (_) => vm.toggleIngredientChecked(item),
                          activeColor: primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: TextStyle(
                              color: item.isChecked ? Colors.grey.shade400 : Colors.grey.shade700,
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              fontSize: 15,
                            )),
                            if (item.notes != null)
                              Text(item.notes!, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                      Text('${item.amount % 1 == 0 ? item.amount.toInt() : item.amount} ${item.unit}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
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
            leading: const Icon(Icons.edit, color: Color(0xFFD32F2F)),
            title: const Text('Sửa'),
            onTap: () { Navigator.pop(ctx); _showEdit(context); },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text('Xóa'),
            onTap: () {
              Navigator.pop(ctx);
              vm.deleteIngredient(item.id!);
            },
          ),
        ]),
      ),
    );
  }

  void _showEdit(BuildContext context) {
    final nameCtrl = TextEditingController(text: item.name);
    final amountCtrl = TextEditingController(text: '${item.amount % 1 == 0 ? item.amount.toInt() : item.amount}');
    final unitCtrl = TextEditingController(text: item.unit);
    final notesCtrl = TextEditingController(text: item.notes ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa Nguyên liệu'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên nguyên liệu')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng')),
            TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Đơn vị')),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Ghi chú')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              vm.updateIngredient(item.copyWith(
                name: nameCtrl.text,
                amount: double.tryParse(amountCtrl.text) ?? item.amount,
                unit: unitCtrl.text,
                notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
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

// ── Steps Section ───────────────────────────────────────────────────────────
class _StepsSection extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish dish;
  const _StepsSection({required this.vm, required this.dish});

  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);

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
                Icon(Icons.menu_book_outlined, color: secondary, size: 22),
                SizedBox(width: 8),
                Text('Cách làm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              ]),
              IconButton(
                icon: const Icon(Icons.add_circle, color: primary),
                onPressed: () => _showAddStep(context),
              ),
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

  void _showAddStep(BuildContext context) {
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

  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);

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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                    boxShadow: const [BoxShadow(color: Color(0x40D32F2F), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Center(child: Text('${step.stepNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16))),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 1.5, margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(border: Border(left: BorderSide(color: primary.withValues(alpha: 0.3), width: 1.5))))),
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
                            Icon(isRunning ? Icons.pause_circle : Icons.timer, size: 16, color: primary),
                            const SizedBox(width: 6),
                            Text(
                              remaining > 0 ? vm.formatTime(remaining) : (step.timerLabel ?? ''),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
                            ),
                          ]),
                        ),
                      ),
                      if (isRunning || remaining < (step.timerMinutes! * 60)) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => vm.resetStepTimer(step.id!),
                          child: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                        ),
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
            leading: const Icon(Icons.edit, color: Color(0xFFD32F2F)),
            title: const Text('Sửa'),
            onTap: () { Navigator.pop(ctx); _showEdit(context); },
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

  void _showEdit(BuildContext context) {
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

// ── Family Secret Section ───────────────────────────────────────────────────
class _FamilySecretSection extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish dish;
  const _FamilySecretSection({required this.vm, required this.dish});

  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color secondary = Color(0xFFFFC107);

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
              child: Transform.rotate(angle: 0.2, child: Icon(Icons.favorite, size: 100, color: primary.withValues(alpha: 0.08))),
            ),
            Positioned(
              top: -16, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [primary, primaryDark]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: secondary, width: 2),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.auto_awesome, size: 16, color: secondary),
                    SizedBox(width: 6),
                    Text('Bí kíp gia truyền', style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
                    SizedBox(width: 6),
                    Icon(Icons.auto_awesome, size: 16, color: secondary),
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
                      Text(secret.title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Text('"${secret.content}"', style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFF374151), height: 1.5)),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditDialog(context, secret),
                          icon: const Icon(Icons.edit_note, color: primary),
                          label: const Text('Sửa bí kíp', style: TextStyle(color: primary)),
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
                        onPressed: () => _showEditDialog(context, null),
                        icon: const Icon(Icons.edit_note, color: primary),
                        label: const Text('Thêm bí kíp gia truyền', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
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

  void _showEditDialog(BuildContext context, FamilySecret? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Thêm bí kíp' : 'Sửa bí kíp'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề (VD: Mẹo của Bà Nội)')),
          const SizedBox(height: 8),
          TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Nội dung bí kíp *')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (contentCtrl.text.isNotEmpty) {
                vm.saveFamilySecret(FamilySecret(
                  id: existing?.id,
                  dishId: dish.id!,
                  title: titleCtrl.text.isEmpty ? null : titleCtrl.text,
                  content: contentCtrl.text,
                  tags: existing?.tags ?? [],
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Bar ──────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish? dish;
  const _BottomBar({required this.vm, this.dish});

  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          border: const Border(top: BorderSide(color: Color(0xFFFEE2E2))),
          boxShadow: const [BoxShadow(color: Color(0x1AD32F2F), blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: Row(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [secondary, Color(0xFFFB923C)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x4DFFC107), blurRadius: 14, offset: Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: dish == null
                      ? null
                      : () {
                          if (vm.isCookTimerRunning) {
                            vm.pauseCookTimer();
                          } else {
                            vm.startCookTimer();
                          }
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(vm.isCookTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: const Color(0xFF7F1D1D)),
                        const SizedBox(width: 8),
                        Text(
                          vm.isCookTimerRunning ? 'Tạm dừng' : 'Bắt đầu nấu ngay',
                          style: const TextStyle(color: Color(0xFF7F1D1D), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.arrow_back, color: primary, size: 24)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

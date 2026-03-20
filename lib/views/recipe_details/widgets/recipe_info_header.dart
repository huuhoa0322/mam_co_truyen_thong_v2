import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_screen.dart'; // Import MainScreen
import '../../../domain/entities/dish.dart';
import '../../../viewmodels/home/home_view_model.dart';
import '../../../viewmodels/recipe_details/recipe_details_view_model.dart';

// ── Color constants ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFD32F2F);
const Color _primaryDark = Color(0xFFB71C1C);
const Color _secondary = Color(0xFFFFC107);
const Color _statsIconColor = _primary;

// ── Hero Image + Stats Card ────────────────────────────────────────────────
class RecipeInfoHeader extends StatelessWidget {
  final Dish? dish;
  const RecipeInfoHeader({super.key, this.dish});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroSection(dish: dish),
        _StatsCard(dish: dish),
      ],
    );
  }
}

// ── Empty state prompt ──────────────────────────────────────────────────────
class EmptyDishPrompt extends StatelessWidget {
  const EmptyDishPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Chưa có món ăn được chọn', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showDishPicker(context),
            icon: const Icon(Icons.search),
            label: const Text('Chọn món ăn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _DishPickerSheet(
        dishes: homeVm.allDishes,
        onDishSelected: (dish) {
          Navigator.pop(ctx); // Close the bottom sheet
          
          // Update the RecipeDetailsViewModel
          final detailsVm = context.read<RecipeDetailsViewModel>();
          detailsVm.loadByDish(dish);
          
          // Ensure we are on the correct tab (optional if we are already there)
          // MainScreen.switchTab(context, 1); 
        },
      ),
    );
  }
}

// ── Dish Picker Sheet ────────────────────────────────────────────────────────
class _DishPickerSheet extends StatefulWidget {
  final List<Dish> dishes;
  final Function(Dish) onDishSelected;

  const _DishPickerSheet({
    required this.dishes,
    required this.onDishSelected,
  });

  @override
  State<_DishPickerSheet> createState() => _DishPickerSheetState();
}

class _DishPickerSheetState extends State<_DishPickerSheet> {
  late TextEditingController _searchController;
  late List<Dish> _filteredDishes;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredDishes = widget.dishes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDishes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDishes = widget.dishes;
      } else {
        _filteredDishes = widget.dishes
            .where((dish) => dish.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Chọn Món Ăn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primary)),
          const SizedBox(height: 12),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterDishes,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                prefixIcon: const Icon(Icons.search, color: _primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _filterDishes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFECEBEB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFECEBEB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Dishes list
          Expanded(
            child: _filteredDishes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_meals, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty ? 'Chưa có món ăn' : 'Không tìm thấy món ăn',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredDishes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final dish = _filteredDishes[i];
                      return _DishListItem(
                        dish: dish,
                        onTap: () => widget.onDishSelected(dish),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Dish List Item ───────────────────────────────────────────────────────────
class _DishListItem extends StatelessWidget {
  final Dish dish;
  final VoidCallback onTap;

  const _DishListItem({
    required this.dish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = dish.imageUrl != null && !dish.imageUrl!.startsWith('http')
        ? Image.file(
            File(dish.imageUrl!),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 60,
              height: 60,
              color: _primary,
              child: const Icon(Icons.restaurant_menu, color: Colors.white),
            ),
          )
        : Image.network(
            dish.imageUrl ?? 'https://cdn-icons-png.flaticon.com/512/3565/3565418.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 60,
              height: 60,
              color: _primary,
              child: const Icon(Icons.restaurant_menu, color: Colors.white),
            ),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageWidget,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⏱️ ${dish.cookTimeMinutes} phút • ${dish.difficulty}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cook Timer Banner ────────────────────────────────────────────────────────
class CookTimerBanner extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  const CookTimerBanner({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_secondary, Color(0xFFFB923C)]),
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
                color: _primary,
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

// ── Bottom Bar ───────────────────────────────────────────────────────────────
class RecipeBottomBar extends StatelessWidget {
  final RecipeDetailsViewModel vm;
  final Dish? dish;
  const RecipeBottomBar({super.key, required this.vm, this.dish});

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
                gradient: const LinearGradient(colors: [_secondary, Color(0xFFFB923C)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x4DFFC107), blurRadius: 14, offset: Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: dish == null ? null : () {
                    vm.isCookTimerRunning ? vm.pauseCookTimer() : vm.startCookTimer();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(vm.isCookTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled, color: const Color(0xFF7F1D1D)),
                        const SizedBox(width: 8),
                        Text(vm.isCookTimerRunning ? 'Tạm dừng' : 'Bắt đầu nấu ngay',
                            style: const TextStyle(color: Color(0xFF7F1D1D), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA))),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => MainScreen.switchTab(context, 0),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.arrow_back, color: _primary, size: 24)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Private: Hero Section ────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Dish? dish;
  const _HeroSection({this.dish});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            child: dish?.imageUrl != null && !dish!.imageUrl!.startsWith('http')
                ? Image.file(File(dish!.imageUrl!), fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: _primaryDark, child: const Center(child: Icon(Icons.restaurant, size: 80, color: Colors.white54))))
                : Image.network(
                    dish?.imageUrl ?? 'https://cdn-icons-png.flaticon.com/512/3565/3565418.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: _primaryDark, child: const Center(child: Icon(Icons.restaurant, size: 80, color: Colors.white54))),
                  ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x33000000), Color(0xCC000000)],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(Icons.arrow_back, () => MainScreen.switchTab(context, 0)),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (dish != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${dish!.cookTimeMinutes} phút', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ]),
                ),
              const SizedBox(height: 8),
              Text(dish?.name ?? 'Chọn món ăn',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
              if (dish?.description != null) ...[
                const SizedBox(height: 2),
                Text(dish!.description!, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.9))),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Material(
    color: Colors.white.withValues(alpha: 0.2),
    shape: const CircleBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, color: Colors.white, size: 24))),
  );
}

// ── Private: Stats Card (editable) ─────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final Dish? dish;
  const _StatsCard({this.dish});

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
              _servingsTile(context),
              Container(width: 1, height: 40, color: Colors.grey.shade500),
              _readonlyTile(Icons.signal_cellular_alt_outlined, 'Độ khó', dish?.difficulty ?? '--'),
              Container(width: 1, height: 40, color: Colors.grey.shade500),
              _readonlyTile(Icons.schedule_outlined, 'Thời gian', dish != null ? '${dish!.cookTimeMinutes} phút' : '--'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _servingsTile(BuildContext context) {
    final value = dish != null ? '${dish!.servingsMin}–${dish!.servingsMax} người' : '--';
    return Expanded(
      child: Column(children: [
        const Icon(Icons.restaurant_menu_outlined, color: _statsIconColor, size: 24),
        const SizedBox(height: 4),
        Text('Khẩu phần', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827), fontSize: 12)),
      ]),
    );
  }

  Widget _readonlyTile(IconData icon, String label, String value) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: _statsIconColor, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
      ]),
    );
  }

}

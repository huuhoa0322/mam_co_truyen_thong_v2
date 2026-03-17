import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../di.dart';
import '../../viewmodels/home/home_view_model.dart';
import 'widgets/featured_dishes.dart';
import 'widgets/category_list.dart';
import 'widgets/new_dishes.dart';

// ─── Color constants ────────────────────────────────────────────────────────
const _tetRed = Color(0xFF8B0000);
const _tetRedLight = Color(0xFFA52A2A);
const _tetGold = Color(0xFFFFD700);
const _tetGoldDim = Color(0xFFC5A000);
const _tetCream = Color(0xFFFFFDD0);

// ─── Main screen ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tetRed,
      body: Stack(
        children: [
          // Scrollable content
          SafeArea(
              bottom: false,
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _tetGold),
                    );
                  }
                  
                  if (viewModel.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Lỗi xuất hiện: ${viewModel.errorMessage}',
                        style: const TextStyle(color: _tetCream),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildSearchBar(),
                        if (viewModel.featuredDishes.isNotEmpty)
                          FeaturedDishesWidget(dishes: viewModel.featuredDishes),
                        CategoryListWidget(categories: viewModel.categories),
                        if (viewModel.recentDishes.isNotEmpty)
                          NewDishesWidget(dishes: viewModel.recentDishes),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xuân Bính Ngựa 2026',
                  style: TextStyle(
                    color: _tetGold,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    decoration: TextDecoration.underline,
                    decorationColor: _tetGold.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Chúc Mừng\n',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      TextSpan(
                        text: 'Năm Mới',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right: notification button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _tetRedLight,
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: _tetGoldDim, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: _tetGold, size: 24),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) => Opacity(
                    opacity: _pulseAnimation.value,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _tetGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: _tetRed, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _tetRedLight.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _tetGoldDim, width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: _tetGold.withValues(alpha: 0.6), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: const TextStyle(color: _tetCream, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm Bánh Chưng, Nem Rán...',
                  hintStyle: TextStyle(
                      color: _tetCream.withValues(alpha: 0.5), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _tetGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _tetGold.withValues(alpha: 0.2), width: 1),
              ),
              child: const Icon(Icons.tune, color: _tetGold, size: 20),
            ),
          ],
        ),
      ),
    );
  }


}

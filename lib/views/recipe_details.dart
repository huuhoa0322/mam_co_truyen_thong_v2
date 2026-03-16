import 'package:flutter/material.dart';

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({super.key});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  // Colors
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color secondary = Color(0xFFFFC107);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color backgroundLight = Color(0xFFFFF8F0);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Ingredient checked states
  final List<bool> _ingredientChecked = [false, true, false, false];

  final List<Map<String, String>> _ingredients = [
    {'name': 'Thịt ba chỉ (cắt miếng vuông)', 'amount': '500g'},
    {'name': 'Trứng vịt (luộc chín)', 'amount': '6 quả'},
    {'name': 'Nước dừa tươi', 'amount': '500ml'},
    {'name': 'Nước mắm ngon', 'amount': '3 muỗng'},
  ];

  bool _showAllIngredients = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(),
                _buildStatsCard(),
                _buildTimerCard(),
                _buildIngredientsSection(),
                _buildStepsSection(),
                _buildFamilySecretSection(),
              ],
            ),
          ),
          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Hero Image Section ──────────────────────────────────────────
  Widget _buildHeroImage() {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCQj3VCmMMCsk3SZ4gzmolyxn1isCv2GoSelv0UsYufGmTwQkTD62gplk3OabufZXq0E3LMO--IZFyqgM1Q9YYjjw67iaeJVOeOXlyywRRpvkViaRQOfgipKs4JngurqgER0TgaffnhILp-K9JssVUzPIAPYyJfkYClzE9bh4iEaGham2auIJfC9ne6jdC52gxVSxUhHCOmwijy_ItHr5hnCLjUGU3o1K0ewIm8-yk4Sdn6iZiZxSRJLxjiI7bp5sQmTTVF9PjqnP_j',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: primaryDark,
                child: const Center(
                  child: Icon(Icons.restaurant, size: 80, color: Colors.white54),
                ),
              ),
            ),
          ),
          // Gradient overlay
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
                  colors: [
                    Colors.transparent,
                    Color(0x33000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Top buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.arrow_back, () {
                  Navigator.of(context).pop();
                }),
                Row(
                  children: [
                    _buildCircleButton(Icons.favorite_border, () {}),
                    const SizedBox(width: 12),
                    _buildCircleButton(Icons.share_outlined, () {}),
                  ],
                ),
              ],
            ),
          ),
          // Bottom info on image
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: secondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFACC15)),
                      ),
                      child: const Text(
                        'MÓN TẾT',
                        style: TextStyle(
                          color: Color(0xFF7F1D1D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '90 phút',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thịt Kho Tàu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hương vị Tết cổ truyền',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  // ── Stats Card ──────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Transform.translate(
        offset: const Offset(0, -24),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              _buildStatItem(Icons.local_fire_department_outlined, 'Calo', '450'),
              _buildDivider(),
              _buildStatItem(Icons.restaurant_menu_outlined, 'Khẩu phần', '4-6'),
              _buildDivider(),
              _buildStatItem(Icons.signal_cellular_alt_outlined, 'Độ khó', 'Trung bình'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade200,
    );
  }

  // ── Timer Card ──────────────────────────────────────────────────
  Widget _buildTimerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [secondary, accentGold],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4DFFC107),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0x80FACC15),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kho thịt',
                    style: TextStyle(
                      color: Color(0xFF7F1D1D),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bước 4 đang thực hiện',
                    style: TextStyle(
                      color: const Color(0xFF7F1D1D).withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Timer + Pause button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '14:25',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F1D1D),
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: primary,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.pause, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Ingredients Section ─────────────────────────────────────────
  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco_outlined, color: secondary, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Nguyên liệu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '8 loại',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Ingredient list
          ...List.generate(_ingredients.length, (index) {
            return _buildIngredientItem(index);
          }),
          // Show all button
          TextButton(
            onPressed: () {
              setState(() {
                _showAllIngredients = !_showAllIngredients;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Xem tất cả nguyên liệu',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                Icon(
                  _showAllIngredients ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(int index) {
    final ingredient = _ingredients[index];
    final checked = _ingredientChecked[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _ingredientChecked[index] = !_ingredientChecked[index];
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: Color(0xFFF3F4F6)),
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
                    child: _buildIngredientItemContent(ingredient, checked, index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientItemContent(Map<String, String> ingredient, bool checked, int index) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: checked,
            onChanged: (val) {
              setState(() {
                _ingredientChecked[index] = val ?? false;
              });
            },
            activeColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            ingredient['name']!,
            style: TextStyle(
              color: checked ? Colors.grey.shade400 : Colors.grey.shade700,
              decoration: checked ? TextDecoration.lineThrough : null,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          ingredient['amount']!,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Steps Section ───────────────────────────────────────────────
  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.menu_book_outlined, color: secondary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Cách làm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Steps with timeline
          _buildStepItem(
            stepNumber: 1,
            title: 'Ướp thịt',
            description:
                'Trộn thịt ba chỉ với tỏi băm, hành tím, nước mắm và đường. Để ướp ít nhất 30 phút cho ngấm gia vị.',
            isActive: true,
            hasTimer: true,
            timerLabel: 'Hẹn giờ (30p)',
          ),
          _buildStepItem(
            stepNumber: 2,
            title: 'Chuẩn bị trứng',
            description:
                'Luộc trứng vịt chín kỹ. Bóc vỏ cẩn thận và để riêng. Bạn có thể chiên sơ qua để tạo lớp vỏ dai ngon nếu thích.',
            isActive: false,
          ),
          _buildStepItem(
            stepNumber: 3,
            title: 'Thắng nước màu & Kho',
            description:
                'Đảo thịt cho săn lại và lên màu đẹp. Thêm nước dừa tươi và đun sôi. Vớt bọt. Cho trứng vào và hạ lửa nhỏ liu riu.',
            isActive: false,
            isLast: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String description,
    bool isActive = false,
    bool hasTimer = false,
    String? timerLabel,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? primary : Colors.white,
                    border: isActive
                        ? null
                        : Border.all(color: primary, width: 2),
                    boxShadow: isActive
                        ? const [
                            BoxShadow(
                              color: Color(0x40D32F2F),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: primary.withValues(alpha: 0.3),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  if (hasTimer) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, size: 16, color: primary),
                          const SizedBox(width: 6),
                          Text(
                            timerLabel ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Family Secret Section ───────────────────────────────────────
  Widget _buildFamilySecretSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFECACA),
            width: 2,
            style: BorderStyle.none,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFECACA),
              width: 2,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background heart icon
              Positioned(
                right: -8,
                bottom: -8,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Icon(
                    Icons.favorite,
                    size: 100,
                    color: primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              // Badge at top
              Positioned(
                top: -16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primary, primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4DFFC107),
                          blurRadius: 14,
                        ),
                      ],
                      border: Border.all(color: secondary, width: 2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: secondary),
                        SizedBox(width: 6),
                        Text(
                          'Bí kíp gia truyền',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.auto_awesome, size: 16, color: secondary),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    // Tip card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFFEE2E2)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Left accent bar
                          Positioned(
                            left: -16,
                            top: 16,
                            child: Container(
                              width: 8,
                              height: 32,
                              decoration: BoxDecoration(
                                color: secondary,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Mẹo của Bà Nội',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                    Text(
                                      'Đã sửa 2 ngày trước',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '"Nhớ dùng nước dừa Xiêm tươi để nước kho ngọt thanh tự nhiên mà không cần thêm quá nhiều đường nhé con."',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF374151),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add note button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_note, color: primary),
                        label: const Text(
                          'Thêm ghi chú riêng của bạn',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Bar ──────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          border: const Border(
            top: BorderSide(color: Color(0xFFFEE2E2)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1AD32F2F),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Start cooking button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [secondary, Color(0xFFFB923C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4DFFC107),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_filled,
                              color: Color(0xFF7F1D1D)),
                          SizedBox(width: 8),
                          Text(
                            'Bắt đầu nấu ngay',
                            style: TextStyle(
                              color: Color(0xFF7F1D1D),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Calendar button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(Icons.event_available_outlined,
                        color: primary, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

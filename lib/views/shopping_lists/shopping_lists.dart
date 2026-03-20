import 'package:flutter/material.dart';

// Shopping Lists Page
class ShoppingListsPage extends StatefulWidget {
  const ShoppingListsPage({super.key});

  @override
  State<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends State<ShoppingListsPage> {
  // Colors
  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFD700);
  static const Color backgroundLight = Color(0xFFFFF8E7);
  static const Color surfaceLight = Color(0xFFFFFCF5);
  static const Color accentRed = Color(0xFFFFEBEE);

  // Shopping items data
  final List<_ShoppingCategory> _categories = [
    _ShoppingCategory(
      icon: Icons.storefront,
      iconBgColor: const Color(0xFFFEF2F2),
      iconColor: primary,
      title: 'Chợ Truyền Thống',
      badge: 'Đồ Tươi',
      items: [
        _ShoppingItem(name: 'Thịt Ba Chỉ', note: 'Kho Tàu', amount: '1 kg', price: '~150k'),
        _ShoppingItem(name: 'Lá Dong', note: 'Gói Bánh Chưng', amount: '5 bó', price: '~50k'),
        _ShoppingItem(name: 'Hành Muối', note: 'Ăn kèm', amount: '1 hũ', price: '45k', checked: true),
      ],
    ),
    _ShoppingCategory(
      icon: Icons.shopping_cart,
      iconBgColor: const Color(0xFFFEF9C3),
      iconColor: const Color(0xFFB45309),
      title: 'Siêu Thị',
      badge: 'Đóng Gói',
      items: [
        _ShoppingItem(name: 'Coca Cola (24 lon)', note: 'Nước ngọt', amount: '2 thùng', price: '~380k'),
        _ShoppingItem(name: 'Dầu Ăn', note: 'Neptune Gold', amount: '2L', price: '~90k'),
      ],
    ),
    _ShoppingCategory(
      icon: Icons.local_mall,
      iconBgColor: const Color(0xFFFFEDD5),
      iconColor: const Color(0xFFEA580C),
      title: 'Thực Phẩm Khô & Đồ Cúng',
      badge: 'Ban Thờ',
      items: [
        _ShoppingItem(name: 'Nhang Trầm', note: 'Loại thượng hạng', amount: '1 hộp', price: '~200k'),
        _ShoppingItem(name: 'Mứt Tết Thập Cẩm', note: 'Hữu Nghị', amount: '1 kg', price: '~120k'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 32),
                        ..._categories.map((category) => Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: _buildCategorySection(category),
                        )),
                        _buildSuggestionCard(),
                      ],
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

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceLight.withValues(alpha: 0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFFEE2E2)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back, color: primary),
                    ),
                  ),
                  const Text(
                    'Danh Sách Đi Chợ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.share, color: primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Budget card
              _buildBudgetCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, Color(0xFFB71C1C), Color(0xFF8B0000)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40D32F2F),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0x4DFACC15)),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFACC15).withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            left: -16,
            bottom: -16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFACC15).withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Ngân Sách Dự Kiến',
                    style: TextStyle(
                      color: const Color(0xFFFEF3C7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      '75% Đã dùng',
                      style: TextStyle(
                        color: Color(0xFFFEF9C3),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '2,450,000',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'VND',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFFEF3C7).withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.75,
                  child: Container(
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đã chi: 1,840,000',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFFFECACA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Còn lại: 610,000',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFFFECACA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFEE2E2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.add_circle, color: Color(0xFFF87171)),
                hintText: 'Thêm món (ví dụ: Giò lụa)',
                hintStyle: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),
        // const SizedBox(width: 12),
        // Container(
        //   decoration: BoxDecoration(
        //     color: surfaceLight,
        //     borderRadius: BorderRadius.circular(16),
        //     border: Border.all(color: const Color(0xFFFEE2E2)),
        //     boxShadow: const [
        //       BoxShadow(
        //         color: Color(0x08000000),
        //         blurRadius: 4,
        //         offset: Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: Material(
        //     color: Colors.transparent,
        //     child: InkWell(
        //       onTap: () {},
        //       borderRadius: BorderRadius.circular(16),
        //       child: const Padding(
        //         padding: EdgeInsets.all(12),
        //         child: Icon(Icons.mic, color: primary),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // ── Category Section ────────────────────────────────────────────
  Widget _buildCategorySection(_ShoppingCategory category) {
    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: category.iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: category.iconColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(category.icon, size: 18, color: category.iconColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  category.badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Items list
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
          child: Column(
            children: List.generate(category.items.length, (index) {
              final item = category.items[index];
              final isLast = index == category.items.length - 1;
              return _buildShoppingItem(item, isLast, category, index);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingItem(_ShoppingItem item, bool isLast, _ShoppingCategory category, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          category.items[index] = _ShoppingItem(
            name: item.name,
            note: item.note,
            amount: item.amount,
            price: item.price,
            checked: !item.checked,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFFEF2F2)),
                ),
        ),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: item.checked,
                onChanged: (val) {
                  setState(() {
                    category.items[index] = _ShoppingItem(
                      name: item.name,
                      note: item.note,
                      amount: item.amount,
                      price: item.price,
                      checked: val ?? false,
                    );
                  });
                },
                activeColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
            ),
            const SizedBox(width: 12),
            // Icon
            Opacity(
              opacity: item.checked ? 0.5 : 1.0,
              child: const Icon(Icons.redeem, size: 18, color: primary),
            ),
            const SizedBox(width: 8),
            // Name & Note
            Expanded(
              child: Opacity(
                opacity: item.checked ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: const Color(0xFF1F2937),
                        decoration: item.checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.note,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Amount & Price
            Opacity(
              opacity: item.checked ? 0.5 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.price,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Suggestion Card ─────────────────────────────────────────────
  Widget _buildSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentRed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -16,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                Icons.local_florist,
                size: 100,
                color: primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCxNu5H_AHrh3TT8v9v6BRyZnLlLDc1JLG67OhQEVsGd0F-epHwZ1X_GKLvzFMGGjOBbpIXJoGlChsSomTWc_ut-t_5J20zeW8RacAKEeoFf91bKHb3m30qwa2O2_fBXQcyQX-TXh4JB7PFk9e1uEVsUHRD89mxqcU3MOdxqNRtegArDsR2xFleXJ587F7oFXb5rx-b7Hq6Pd2VXDrtvjtJ0GiEm7KSv21c5uh3BerYD04AxTGUAw5bhhHQpTPCQebL4jvUaBVJhkPW',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFFECACA),
                    child: const Icon(Icons.fastfood, color: primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thiếu nguyên liệu Bánh Chưng?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bạn đã có 2 món, nhưng vẫn thiếu Đậu Xanh và Gạo Nếp.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Thêm Đồ Thiếu',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

// ── Data Models ─────────────────────────────────────────────────
class _ShoppingCategory {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String badge;
  final List<_ShoppingItem> items;

  _ShoppingCategory({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.badge,
    required this.items,
  });
}

class _ShoppingItem {
  final String name;
  final String note;
  final String amount;
  final String price;
  final bool checked;

  _ShoppingItem({
    required this.name,
    required this.note,
    required this.amount,
    required this.price,
    this.checked = false,
  });
}


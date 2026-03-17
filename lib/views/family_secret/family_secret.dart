import 'package:flutter/material.dart';

// Family Secret Page
class FamilySecretPage extends StatefulWidget {
  const FamilySecretPage({super.key});

  @override
  State<FamilySecretPage> createState() => _FamilySecretPageState();
}

class _FamilySecretPageState extends State<FamilySecretPage> {
  // Colors
  static const Color primary = Color(0xFFA9231C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4E5B0);
  static const Color parchment = Color(0xFFFDF6E3);
  static const Color backgroundLight = Color(0xFFF7EEDD);
  static const Color paper = Color(0xFFFFFDF5);
  static const Color sepia = Color(0xFF704214);

  int _selectedFilterIndex = 0;

  final List<String> _filters = ['Tất cả', 'Bánh Chưng', 'Dưa Hành', 'Thịt Kho'];

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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildBanhChungCard(),
                        const SizedBox(height: 32),
                        _buildThitKhoCard(),
                        const SizedBox(height: 32),
                        _buildDuaHanhCard(),
                        const SizedBox(height: 32),
                        _buildMutTetCard(),
                        const SizedBox(height: 40),
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
      color: backgroundLight,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Kho Tàng Bí Kíp',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 2,
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Transform.rotate(
                        angle: -0.02,
                        child: const Text(
                          'Gia Truyền',
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF57534E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Settings button
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: paper.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.tune, color: Color(0xFF57534E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gold.withValues(alpha: 0.4), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Color(0xFFA8A29E)),
                    hintText: 'Tìm kiếm công thức của Mẹ...',
                    hintStyle: TextStyle(
                      color: Color(0xFFA8A29E),
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedFilterIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? primary : paper,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primary : gold.withValues(alpha: 0.4),
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isSelected ? Colors.white : const Color(0xFF57534E),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Bánh Chưng Card (Scrapbook style) ───────────────────────────
  Widget _buildBanhChungCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Tape on top
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.rotate(
              angle: 0.02,
              child: Container(
                width: 96,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6D5AC).withValues(alpha: 0.8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                  border: Border.symmetric(
                    vertical: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Main card
        Container(
          decoration: BoxDecoration(
            color: paper,
            border: Border.all(color: gold),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: primary.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                // Image section
                SizedBox(
                  height: 208,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.matrix([
                          0.9, 0.1, 0.1, 0, 10,
                          0.05, 0.85, 0.05, 0, 5,
                          0.05, 0.05, 0.8, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDTbm4cSNVugeVcs_QvMlEPHhsXrukeSqLiJ0vJ7BUnNsBwCLNLo2YIpONk1i9d2L3CSCkuNtiuO3JZ3rV4l7ttYKEUv3lXidgZMlX2IqdBCB3vWZWdtQbwuH6XSiTWwpn1UAp56xinjkfCHmDsdiVDPn5iAZvV_uonC_9kmnYBgXuZCk2jf_cNGkMMWvDQhDbQxR9yotwvyYBzoAl-IccDWUMP97K7OvuNCNi0W-LD5HDqMR6aeR8FFxuBs6yghcZbx2tYmOfDvx5L',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: sepia.withValues(alpha: 0.2),
                            child: const Center(child: Icon(Icons.restaurant, size: 60, color: Colors.white54)),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xCC000000)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bánh Chưng Bà Nội',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: goldLight,
                                  letterSpacing: 0.5,
                                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Công thức gốc của Bà • 1985',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xE6FFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: paper.withValues(alpha: 0.9),
                            border: Border.all(color: gold.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium, size: 14, color: primary),
                              SizedBox(width: 4),
                              Text(
                                'Gia Bảo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Small note image
                    Positioned(
                      right: -8,
                      top: -32,
                      child: Transform.rotate(
                        angle: 0.05,
                        child: Container(
                          width: 96,
                          height: 96,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFDE),
                            border: Border.all(color: const Color(0xFFE7E5E4)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x30000000), blurRadius: 8, offset: Offset(2, 2)),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAVROLcscGK9zJ1eCiQEpFbYFMfsWU3oYD1kHZmzBUqFozv-3U2fjdviiatQZ2CeVr7K-AIC13flPwPZ8k8WAyQFPya9hpi98a33ouFCj_fIKuUBZlHGvZvNttJ1SxhZWeuoi3S6j2SmHQVFYWAvopWVzI71r0uRQpeqLNppn_aeCNjSKTAFMlpjJr3x7NpbM0KFfj7pkq5KcMCiOrawossAP4NUUuTj8gJZ_pbogMoYIHDURh6dk5OdsxStYNY6u2SQeb3tQnlR36F',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(color: const Color(0xFFE7E5E4)),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Text(
                                  'Ghi chú của Bà',
                                  style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Secret label
                          Padding(
                            padding: const EdgeInsets.only(right: 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Color(0x33A9231C))),
                                  ),
                                  child: const Text(
                                    'BÍ QUYẾT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '"Nhớ ngâm gạo nếp ít nhất 8 tiếng. Bí quyết nằm ở lá dong—rửa thật sạch nhưng nhẹ tay để giữ màu xanh..."',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF57534E),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Footer
                          Container(
                            padding: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: gold.withValues(alpha: 0.2),
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        border: Border.all(color: primary.withValues(alpha: 0.2)),
                                      ),
                                      child: const Text(
                                        'BÍ MẬT',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cập nhật 2 ngày trước',
                                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Xem chi tiết',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward, size: 16, color: primary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Thịt Kho Tàu Card (Book style) ─────────────────────────────
  Widget _buildThitKhoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: paper,
        border: Border.all(color: const Color(0xFFD6D3D1)),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 15, offset: Offset(5, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Transform.rotate(
                angle: -0.03,
                child: Container(
                  width: 96,
                  height: 112,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE7E5E4)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(1, 2)),
                    ],
                  ),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDmEeBXkewFALYNrKAiOOSB2B82tjmfnJf_wNHLc7Loj82sjXXJXLm1QwLBUK_2SvAGSw0mQlpVxPh1SKxspWohl7uFvUM6eQ3ZeVoA8IyZRVh9y3q34wA1WNiCWyosjM7P_wHThO8AqYWq1iqhj-MI-xGNtEBAJO7RnJJ2Tf2wxiAPEbbQyirMOjoEHEDkP-6uh7_ameL27Fzpfx6iCCY0UJPmPq_0VeLloOeeeMDDSeSJkuSA40AApr09HTcQO7VA_wjwcGauRymo',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: const Color(0xFFE7E5E4)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thịt Kho Tàu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF292524),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Món tủ của Mẹ',
                              style: TextStyle(
                                fontSize: 16,
                                color: primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.favorite, color: primary.withValues(alpha: 0.8), size: 22),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Quote
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: parchment,
                        border: Border(left: BorderSide(color: gold, width: 2)),
                      ),
                      child: const Text(
                        '"Dùng nước dừa tươi để có vị ngọt thanh, không cần thêm đường!"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF57534E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tags
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: const Color(0xFFE7E5E4))),
            ),
            child: Row(
              children: [
                _buildTag('Kho Lửa Nhỏ'),
                const SizedBox(width: 8),
                _buildTag('Phải Thử'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4),
        border: Border.all(color: const Color(0xFFE7E5E4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontStyle: FontStyle.italic,
          letterSpacing: 1,
          color: Color(0xFF57534E),
        ),
      ),
    );
  }

  // ── Dưa Hành Card (Polaroid style) ──────────────────────────────
  Widget _buildDuaHanhCard() {
    return Center(
      child: Transform.rotate(
        angle: 0.02,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE7E5E4)),
            boxShadow: const [
              BoxShadow(color: Color(0x30000000), blurRadius: 12, offset: Offset(2, 4)),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Pin
              Positioned(
                top: -12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFB91C1C),
                      border: Border.all(color: const Color(0xFF7F1D1D), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Align(
                      alignment: const Alignment(0.3, -0.3),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF87171).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                child: Column(
                  children: [
                    // Image
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF5F5F4)),
                        ),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCy4ADvDNtkUXvshvn2sTFe7zPvd745gMTa8VNy2caBu2r61txu13yQqI8ERISIWi0KuMxcWy4Ze7Ta7IgyT-q8Ipr3fcvT8jCQr9EF3IWoxeZ2uh4ye1zSzKdAZ8kAYj1UonYK5pbuld8Vjz13cesL2KXQe12T2badblfn4_NLm49oC39IWJejjyBtRFYq3mX9PMaIWbQNnB2pB8xQZlvp9RvSYp1knSQsUvk54qDnoni9lF1kPVUtCNzcFYXyOgzKYZYmiq3y2b-s',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(color: const Color(0xFFF5F5F4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.rotate(
                                angle: -0.02,
                                child: const Text(
                                  'Dưa Hành Muối',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF292524),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ghi bởi Dì Lan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          // Stars
                          Row(
                            children: [
                              ...List.generate(3, (_) => const Icon(Icons.star, size: 16, color: gold)),
                              const Icon(Icons.star_half, size: 16, color: gold),
                            ],
                          ),
                        ],
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

  // ── Mứt Tết Card (Simple list item) ─────────────────────────────
  Widget _buildMutTetCard() {
    return Container(
      decoration: BoxDecoration(
        color: paper,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: const Color(0xFFE7E5E4)),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Các loại Mứt Tết',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF292524),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gừng, dừa, hạt sen và bí đao.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: parchment,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD6D3D1)),
                      ),
                      child: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF78716C)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

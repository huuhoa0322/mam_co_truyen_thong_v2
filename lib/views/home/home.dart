import 'package:flutter/material.dart';

// ─── Color constants ────────────────────────────────────────────────────────
const _tetRed = Color(0xFF8B0000);
const _tetRedLight = Color(0xFFA52A2A);
const _tetGold = Color(0xFFFFD700);
const _tetGoldDim = Color(0xFFC5A000);
const _tetCream = Color(0xFFFFFDD0);
const _cardGradientStart = Color(0xFF9E1B1B);
const _cardGradientEnd = Color(0xFF800000);

// ─── Data models ────────────────────────────────────────────────────────────
class _Category {
  final String label;
  final String imageUrl;
  const _Category(this.label, this.imageUrl);
}

class _Recipe {
  final String name;
  final String description;
  final String difficulty;
  final Color difficultyColor;
  final Color difficultyBg;
  final String time;
  final String imageUrl;
  const _Recipe({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.difficultyColor,
    required this.difficultyBg,
    required this.time,
    required this.imageUrl,
  });
}

const _categories = [
  _Category(
    'Mâm Cỗ',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDwNlKPcIFjg6MUI9IVMtOqxVyw2fwhhRftTZVTTVNA0W8tjrvw7tL3i7MrSfoqEZ-3zdwo2Se9XWtvZtEIAXzB13LkGFwXQGYwWu59FJFoYmsbFdR3AJOmM9uBAFqAHeoIWdUwqquDGBsQ3FGCfTDE3Hl80L-gimy7vv-Y1H6qVZXOsLjKQT7BkM9qSCzb2O_bpqX32_HllXvsCsC88Vo_qbojOfUVs6II9Ux-LzcaMtEfojH-UodKuLGRm86_zW2MNFNd-24ND1jS',
  ),
  _Category(
    'Tráng Miệng',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD5uGM9VZlKoquK7zkl9RpVWTxlv6WZNElUtScfa4bNhlFcEhVqx4S13cwqwzkkh990QC6xvuhHkW1DVZWBPq2LLoIDcyPw0D0rYLK-I-nP7_g3DUAkWGJxnRgM3xDabXMKWkbl6jl3A7vK3pvmnE8QUqWPhbGWjx5ywUC6nWpJRvhMuTUNl2gJcF5eV6wKCOZpW7ZVEqv_CE3D3NfyZDOstUzo1GbALNrT_bYtsyhDrm5TVJzImuqS7evgUD_zMyD2O7GWD48aiNcN',
  ),
  _Category(
    'Món Chay',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCu5ZkfhhdAhxQjX5zvvUwaUJWmGlAhgFfBnITtEudJjZE-PWVcEJnLVBv3cX60ZcRTeQtQagePhokfLCifCTFEHE25VqXg5GB10NXO_9sBRaHrpbqnvAKQhS70AV3CxTxggahlz8_MFQcbM3eU0L8TBv3PGUFY5jE5bu4vD6h9CUIoWYOo7yW4ox2QntlSceWrHYL8ljou9z8T1g1c7Ib4O40m44TWslcfLE6gmD5BJwm_kU3UC3wZoyq8sPjqxEyXeXxixH9T1sgA',
  ),
  _Category(
    'Ăn Vặt Tết',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB7-1mE4RQE5OiUCD0aqnTq1AWpAE8diY-HDpqsymYtHQPzznq_DLcFbWUbGducUd_KBXMQqdqdJKak_W86ceHcyB4QjEs1MjxTPq4hTyet9FkYA4ic5rJRUCAC6VXlTLltBW0bLFc3HS7IEJrT1YbQvahoSIUvXUrIemxRLnPR37H0Q2ax8GIgtd-bkaQLpnowFjmlYtmLDGpXvvu7rkC1qahOZKcaQTzviCmbOQ3ZqKQSkxkjBLOQJrrU32EqcQ-cqhmL7jQg244z',
  ),
];

const _recipes = [
  _Recipe(
    name: 'Thịt Kho Tàu',
    description: 'Thịt ba chỉ kho trứng đậm đà hương vị Tết.',
    difficulty: 'Dễ',
    difficultyColor: _tetGold,
    difficultyBg: Color(0x1AFFD700),
    time: '90p',
    imageUrl:
        '',
  ),
  _Recipe(
    name: 'Nem Rán',
    description: 'Chả giò giòn rụm, hương vị truyền thống.',
    difficulty: 'Trung bình',
    difficultyColor: Color(0xFFFDA47A),
    difficultyBg: Color(0x1AFB923C),
    time: '45p',
    imageUrl:
        '',
  ),
  _Recipe(
    name: 'Mứt Dừa',
    description: 'Sợi dừa ngọt ngào đãi khách ngày Xuân.',
    difficulty: 'Dễ',
    difficultyColor: _tetGold,
    difficultyBg: Color(0x1AFFD700),
    time: '30p',
    imageUrl:
        '',
  ),
];

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
  int _selectedNav = 0;
  bool _isBookmarked = false;
  final List<bool> _likes = [false, false, false];

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildFeaturedSection(),
                  _buildCollectionSection(),
                  _buildMustTrySection(),
                ],
              ),
            ),
          ),
          // Bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(),
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

  // ── Featured section ──────────────────────────────────────────────────────
  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant,
                      color: _tetGold, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Gợi Ý Món Ngon',
                    style: TextStyle(
                      color: _tetGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: _tetCream.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hero card
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _tetGold.withValues(alpha: 0.5), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 16)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDUu9_8SosFySEfqkss9IgSx9i2ZdzO9R8dYBIz9eFLkkHKvAS7VE0upIzM0Rzx2cfsTxwoeWMkMRdIWjItY4Zl56u7g5FPNf19mbA8JaW3SVcN26aju9NqoVu54NowXd8bfEqb6IEBhANCW-YWU4CcUN1_Lr_C4f5iF8MzVFjnT-VsGKg3cNL02AxORLc94GSBC7d88NqQJetV9Dz-njuh9vnej-DfrR7urSR8Jn9nE_St_mSsH52o-x4o84GOZ3cSF0ba9rIpQRvO',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: _tetRedLight),
                    ),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.90),
                            Colors.black.withValues(alpha: 0.40),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.45, 1],
                        ),
                      ),
                    ),
                    // "Nổi bật" badge — top right
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _tetRed.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: _tetGold, width: 1),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black38, blurRadius: 8)
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department,
                                color: _tetGold, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Nổi bật',
                              style: TextStyle(
                                  color: _tetGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tags + stars
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _tetGold,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'MÓN CHÍNH',
                                    style: TextStyle(
                                      color: _tetRed,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: _tetGold, size: 14),
                                    Icon(Icons.star,
                                        color: _tetGold, size: 14),
                                    Icon(Icons.star,
                                        color: _tetGold, size: 14),
                                    Icon(Icons.star,
                                        color: _tetGold, size: 14),
                                    Icon(Icons.star_half,
                                        color: _tetGold, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      '(128)',
                                      style: TextStyle(
                                        color: Color(0xCCFFFDD0),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Title
                            const Text(
                              'Bánh Chưng Truyền Thống',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Meta row
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _metaChip(
                                        Icons.schedule, '8 giờ'),
                                    const SizedBox(width: 16),
                                    _metaChip(
                                        Icons.bar_chart, 'Khó'),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _isBookmarked = !_isBookmarked),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: _tetGold
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Icon(
                                      _isBookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: _tetGold,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: _tetCream.withValues(alpha: 0.9), size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              color: _tetCream.withValues(alpha: 0.9), fontSize: 13),
        ),
      ],
    );
  }

  // ── Collection section ────────────────────────────────────────────────────
  Widget _buildCollectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'Bộ Sưu Tập Tết',
            style: TextStyle(
              color: _tetGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, i) => _buildCategoryItem(_categories[i]),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCategoryItem(_Category cat) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _tetRedLight,
                shape: BoxShape.circle,
                border:
                    Border.all(color: _tetGold.withValues(alpha: 0.5), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6)
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  cat.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported,
                          color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cat.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tetCream,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Must-try section ──────────────────────────────────────────────────────
  Widget _buildMustTrySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.ramen_dining, color: _tetGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Món Ngon Phải Thử',
                style: TextStyle(
                  color: _tetGold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _recipes.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildRecipeCard(_recipes[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(_Recipe recipe, int index) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/recipe_details'),
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardGradientStart, _cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _tetGoldDim, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                border: Border.all(
                    color: _tetGold.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: _tetRedLight),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _likes[index] = !_likes[index]),
                      child: Icon(
                        _likes[index]
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _likes[index]
                            ? Colors.redAccent
                            : _tetGold.withValues(alpha: 0.6),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _tetCream.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: recipe.difficultyBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: recipe.difficultyColor.withValues(alpha: 0.4),
                            width: 1),
                      ),
                      child: Text(
                        recipe.difficulty,
                        style: TextStyle(
                          color: recipe.difficultyColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer_outlined,
                        color: _tetCream.withValues(alpha: 0.6), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      recipe.time,
                      style: TextStyle(
                          color: _tetCream.withValues(alpha: 0.6), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _tetRed.withValues(alpha: 0.95),
        border: Border(
            top: BorderSide(color: _tetGold.withValues(alpha: 0.3), width: 1)),
        boxShadow: const [
          BoxShadow(
              color: Colors.black45, blurRadius: 10,
              offset: Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, 'Trang Chủ', 0, filled: true),
              _navItem(Icons.auto_stories, 'Bí Kíp', 1, route: '/family_secret'),
              // Center FAB
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/recipe_details'),
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFEAB308)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: _tetRed, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: _tetGold.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.restaurant_menu,
                        color: _tetRed, size: 28),
                  ),
                ),
              ),
              _navItem(Icons.shopping_cart_outlined, 'Đi Chợ', 3, route: '/shopping_lists'),
              _navItem(Icons.person_outline, 'Cá Nhân', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index,
      {bool filled = false, String? route}) {
    final isActive = _selectedNav == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNav = index);
        if (route != null) {
          Navigator.of(context).pushNamed(route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? _tetGold : _tetCream.withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight:
                  isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? _tetGold : _tetCream.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

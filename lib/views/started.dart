import 'dart:math';
import 'package:flutter/material.dart';


class StartedScreen extends StatefulWidget {
  const StartedScreen({super.key});

  @override
  State<StartedScreen> createState() => _StartedScreenState();
}

class _StartedScreenState extends State<StartedScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _twinkleController;
  late Animation<double> _floatAnimation;
  late Animation<double> _twinkleAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _twinkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _twinkleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _twinkleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B0000), Color(0xFF5E0000)],
          ),
        ),
        child: Stack(
          children: [
            // Firework twinkle particles
            _buildFireworks(context),
            // Falling apricot blossoms
            const FallingBlossomsWidget(),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          // Hero image with float animation
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24.0),
                              child: AnimatedBuilder(
                                animation: _floatAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _floatAnimation.value),
                                    child: child,
                                  );
                                },
                                child: _buildHeroImage(),
                              ),
                            ),
                          ),
                          // Bottom content
                          _buildBottomContent(),
                          const SizedBox(height: 32),
                        ],
                      ),
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

  Widget _buildFireworks(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _twinkleAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top-left firework — yellow
            Positioned(
              top: size.height * 0.10,
              left: size.width * 0.10,
              child: Opacity(
                opacity: _twinkleAnimation.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBBF24),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFBBF24),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Top-left sub-particle — red
            Positioned(
              top: size.height * 0.10 - 20,
              left: size.width * 0.10 + 20,
              child: Opacity(
                opacity: _twinkleAnimation.value * 0.8,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF87171),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF87171),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Top-right firework — orange
            Positioned(
              top: size.height * 0.15,
              right: size.width * 0.10,
              child: Opacity(
                opacity: _twinkleAnimation.value * 0.7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDBA74),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFDBA74),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Left-middle firework — pale yellow
            Positioned(
              top: size.height * 0.40,
              left: size.width * -0.05 + 12,
              child: Opacity(
                opacity: _twinkleAnimation.value * 0.6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF08A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFEF08A),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0x4DFFD700), // gold 30% opacity
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000), // black 50% opacity
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDNGq1PNj83xTAgUayK5dWkb93jeTXUD4XmXcWWhAHUH1A1r4Y7b6_YSzCEe1AGwecj9VQNS1KzqQF9Rrfn9p4h_nlOzrrWFkB6IZihJPEnsoFhJp5f-i0JaK7hYcoYptILd_3GC52MJ3wH9m34AwgRW5Q7Q8AIy-SYyQ88J6Shst4DdkzWIELvk2z2UTRGTgjGiKLTBLHCEjjjcZQBw4enwg8D02F1jR0xT-IDKxM4MeALZ3XjhHAqEhfNIKhJZLZFQvI_FaANKjE1',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF8B0000),
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white54, size: 48),
                  ),
                ),
              ),
            ),
            // Gradient overlay (bottom fade)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF5E0000).withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Badge — top right
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA2A33).withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Color(0xFFFCD34D),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Tết Bính Ngọ',
                      style: TextStyle(
                        color: Color(0xFFFEF3C7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
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

  Widget _buildBottomContent() {
    return Column(
      children: [
        // Title
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Khơi nguồn\n',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                  shadows: [
                    Shadow(blurRadius: 10, color: Colors.black54),
                  ],
                ),
              ),
              TextSpan(
                text: 'phong vị Tết Việt',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFACC15),
                  height: 1.3,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Subtitle
        const Text(
          'Khơi dậy hương vị Tết truyền thống ngay trong căn bếp của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFFCDD2),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFFACC15),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFBBF24), blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // CTA Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFACC15),
                  Color(0xFFF59E0B),
                  Color(0xFFEAB308),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bắt đầu ngay',
                    style: TextStyle(
                      color: Color(0xFF5E0000),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF5E0000),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Falling apricot blossoms ───────────────────────────────────────────────

class FallingBlossomsWidget extends StatefulWidget {
  const FallingBlossomsWidget({super.key});

  @override
  State<FallingBlossomsWidget> createState() => _FallingBlossomsWidgetState();
}

class _FallingBlossomsWidgetState extends State<FallingBlossomsWidget>
    with TickerProviderStateMixin {
  static const _config = [
    //  left%  dur  delay  opacity  scale
    [0.10, 12, 0, 0.80, 1.0],
    [0.25, 15, 2, 0.60, 0.8],
    [0.40, 10, 5, 0.90, 1.0],
    [0.60, 14, 1, 0.70, 1.2],
    [0.75, 18, 4, 0.50, 0.6],
    [0.85, 11, 7, 0.80, 1.0],
    [0.05, 16, 9, 0.60, 1.0],
    [0.95, 13, 3, 0.70, 1.0],
  ];

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = _config
        .map((c) => AnimationController(
              duration: Duration(seconds: c[1].toInt()),
              vsync: this,
            ))
        .toList();

    _animations = _controllers
        .map((ctrl) => Tween<double>(begin: -0.05, end: 1.05).animate(
              CurvedAnimation(parent: ctrl, curve: Curves.linear),
            ))
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(seconds: _config[i][2].toInt()), () {
        if (mounted) _controllers[i].repeat();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  double _currentOpacity(int i) {
    final v = _animations[i].value;
    if (v > 0.9) return (_config[i][3] * (1 - (v - 0.9) * 10)).toDouble();
    if (v < 0.1) return (_config[i][3] * (v * 10)).toDouble();
    return _config[i][3].toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: List.generate(_config.length, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            return Positioned(
              top: _animations[i].value * size.height,
              left: _config[i][0] * size.width,
              child: Opacity(
                opacity: _currentOpacity(i).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: _animations[i].value * 2 * pi,
                  child: Transform.scale(
                    scale: _config[i][4].toDouble(),
                    child: CustomPaint(
                      size: const Size(16, 16),
                      painter: _StarBlossomPainter(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _StarBlossomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = const Color(0xFFFFA500)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final fillPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.4;
    const points = 5;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

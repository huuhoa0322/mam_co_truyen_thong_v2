import 'package:flutter/material.dart';
import '../../../domain/entities/dish.dart';

const _tetRedLight = Color(0xFFA52A2A);
const _tetGold = Color(0xFFFFD700);
const _tetGoldDim = Color(0xFFC5A000);
const _tetCream = Color(0xFFFFFDD0);
const _cardGradientStart = Color(0xFF9E1B1B);
const _cardGradientEnd = Color(0xFF800000);

class NewDishesWidget extends StatefulWidget {
  final List<Dish> dishes;
  
  const NewDishesWidget({super.key, required this.dishes});

  @override
  State<NewDishesWidget> createState() => _NewDishesWidgetState();
}

class _NewDishesWidgetState extends State<NewDishesWidget> {
  final List<bool> _likes = [false, false, false]; // Tạm thời hardcode data tĩnh

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
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
          ...List.generate(
            widget.dishes.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDishCard(widget.dishes[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(Dish dish, int index) {
    if (_likes.length <= index) {
      _likes.add(false); // dynamically add like statuses 
    }
    
    // Convert difficulty
    Color difficultyColor = _tetGold;
    Color difficultyBg = const Color(0x1AFFD700);
    if (dish.difficulty == 'Trung bình') {
      difficultyColor = const Color(0xFFFDA47A);
      difficultyBg = const Color(0x1AFB923C);
    } else if (dish.difficulty == 'Khó') {
      difficultyColor = Colors.redAccent;
      difficultyBg = const Color(0x1AFF0000);
    }

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
                  border: Border.all(color: _tetGold.withValues(alpha: 0.3), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  dish.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: _tetRedLight),
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
                        dish.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _likes[index] = !_likes[index]),
                        child: Icon(
                          _likes[index] ? Icons.favorite : Icons.favorite_border,
                          color: _likes[index] ? Colors.redAccent : _tetGold.withValues(alpha: 0.6),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.description ?? '',
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: difficultyBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: difficultyColor.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Text(
                          dish.difficulty,
                          style: TextStyle(
                            color: difficultyColor,
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
                        '${dish.cookTimeMinutes}p',
                        style: TextStyle(color: _tetCream.withValues(alpha: 0.6), fontSize: 11),
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
}

import 'package:flutter/material.dart';
import '../../../domain/entities/category.dart';

const _tetRedLight = Color(0xFFA52A2A);
const _tetGold = Color(0xFFFFD700);
const _tetCream = Color(0xFFFFFDD0);

class CategoryListWidget extends StatelessWidget {
  final List<Category> categories;
  
  const CategoryListWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Bộ Sưu Tập',
                style: TextStyle(
                  color: _tetGold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length + 1, // Add 1 for the Create Button
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _buildAddCategoryItem();
              }
              return _buildCategoryItem(categories[i - 1]);
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAddCategoryItem() {
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
                color: _tetRedLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: _tetGold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(
                Icons.add,
                color: _tetGold,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tạo mới\nBộ sưu tập',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
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

  Widget _buildCategoryItem(Category cat) {
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
                border: Border.all(color: _tetGold.withValues(alpha: 0.5), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6)
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  cat.coverImageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported, color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cat.name,
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
}

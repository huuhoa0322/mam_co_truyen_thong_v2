import 'package:flutter/material.dart';
import '../../../domain/entities/family_secret.dart';
import '../../../domain/entities/dish.dart';
import '../../../viewmodels/family_secret/secret_view_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';
class SecretList extends StatelessWidget {
  final List<FamilySecret> secrets;
  final SecretViewModel vm;
  final Function(FamilySecret) onEdit;
  final Function(int) onDelete;

  const SecretList({
    super.key,
    required this.secrets,
    required this.vm,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (secrets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.menu_book, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'Chưa có bí kíp nào trong Kho Tàng.',
                style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: secrets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 32),
      itemBuilder: (context, index) {
        final secret = secrets[index];
        final dish = vm.getDishForSecret(secret);
        return _SecretCard(
          secret: secret,
          dish: dish,
          onEdit: () => onEdit(secret),
          onDelete: () => onDelete(secret.id!),
        );
      },
    );
  }
}

class _SecretCard extends StatelessWidget {
  final FamilySecret secret;
  final Dish? dish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SecretCard({
    required this.secret,
    required this.dish,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color primary = Color(0xFFA9231C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4E5B0);
  static const Color paper = Color(0xFFFFFDF5);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final String updateDate = secret.updatedAt != null 
        ? dateFormat.format(secret.updatedAt!) 
        : 'Gần đây';

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
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                // Dish Image & Title section
                SizedBox(
                  height: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImage(dish, secret.coverImageUrl),
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
                                dish?.name ?? 'Món Chưa Rõ',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: goldLight,
                                  letterSpacing: 0.5,
                                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                                ),
                              ),
                              if (dish?.description != null && dish!.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    dish!.description!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xE6FFFFFF),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Edit/Delete controls top right
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            _buildCircleButton(Icons.edit, onEdit),
                            const SizedBox(width: 8),
                            _buildCircleButton(Icons.delete_outline, onDelete, isDestructive: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tags Section
                if (secret.tags.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: const Color(0xFFE7E5E4))),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: secret.tags.map((t) => _buildTag(t)).toList(),
                    ),
                  ),
                  
                // Secret Content section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Secret title label
                      Container(
                        padding: const EdgeInsets.only(bottom: 4),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0x33A9231C))),
                        ),
                        child: Text(
                          (secret.title?.toUpperCase() ?? 'BÍ QUYẾT'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"${secret.content}"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF57534E),
                          height: 1.5,
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
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                border: Border.all(color: primary.withValues(alpha: 0.2)),
                              ),
                              child: const Text(
                                'GIA TRUYỀN',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cập nhật $updateDate',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
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
      ],
    );
  }

  Widget _buildImage(Dish? dish, String? coverImageUrl) {
    final url = (coverImageUrl != null && coverImageUrl.isNotEmpty) ? coverImageUrl : dish?.imageUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http')) {
        return Image.network(url, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder());
      } else if (url.startsWith('assets/')) {
        return Image.asset(url, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder());
      } else {
        return Image.file(File(url), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder());
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF704214).withValues(alpha: 0.2),
      child: const Center(child: Icon(Icons.restaurant, size: 60, color: Colors.white54)),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4),
        border: Border.all(color: const Color(0xFFE7E5E4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          color: Color(0xFF57534E),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDestructive ? Colors.red.shade700 : primary,
        ),
      ),
    );
  }
}

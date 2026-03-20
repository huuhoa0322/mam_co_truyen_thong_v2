import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/family_secret.dart';
import '../../domain/entities/category.dart';
import '../../viewmodels/family_secret/secret_view_model.dart';
import 'widgets/secret_list.dart';
import 'widgets/create_secret_modal.dart';

class FamilySecretPage extends StatelessWidget {
  const FamilySecretPage({super.key});

  static const Color primary = Color(0xFFA9231C); // Đỏ mâm cỗ
  static const Color background = Color(0xFFF9F7F1); // Nền giấy

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Consumer<SecretViewModel>(
          builder: (context, vm, child) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildFilterSection(context, vm),
                        const SizedBox(height: 24),
                        
                        if (vm.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(color: primary),
                            ),
                          )
                        else if (vm.errorMessage != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                vm.errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          )
                        else
                          SecretList(
                            secrets: vm.filteredSecrets,
                            vm: vm,
                            onEdit: (secret) => _showSecretActionModal(context, secret),
                            onDelete: (id) => _confirmDelete(context, vm, id),
                          ),
                        const SizedBox(height: 100), // Padding cho nút nổi
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSecretActionModal(context, null),
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: const Text(
          'Kho Tàng Bí Kíp',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        background: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.auto_stories, size: 200, color: primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, SecretViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bộ Sưu Tập',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF57534E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildFilterChip('Tất cả', null, vm.selectedCategory == null, () {
                vm.setFilter(null);
              }),
              ...vm.categories.map((c) => _buildFilterChip(
                    c.name,
                    c,
                    vm.selectedCategory?.id == c.id,
                    () => vm.setFilter(c),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, Category? category, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF78716C),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showSecretActionModal(BuildContext context, FamilySecret? secret) {
    final vm = context.read<SecretViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: vm,
        child: CreateSecretModal(
          initialSecret: secret,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SecretViewModel vm, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa Bí Kíp?'),
        content: const Text('Bạn có chắc chắn muốn xóa bí kíp gia truyền này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteSecret(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa bí kíp khỏi Kho Tàng.')),
              );
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}

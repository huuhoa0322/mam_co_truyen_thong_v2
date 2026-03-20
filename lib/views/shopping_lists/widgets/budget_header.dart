import 'dart:math';
import 'package:flutter/material.dart';

class BudgetHeader extends StatelessWidget {
  final int totalEstimatedBudget;
  final int totalActualSpent;

  const BudgetHeader({
    super.key,
    required this.totalEstimatedBudget,
    required this.totalActualSpent,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFD32F2F);
    const Color secondary = Color(0xFFFFD700);

    final remaining = max(0, totalEstimatedBudget - totalActualSpent);
    final percentage = totalEstimatedBudget > 0 
        ? (totalActualSpent / totalEstimatedBudget)
        : 0.0;
    
    final barPercentage = percentage.clamp(0.0, 1.0);
    final percentageText = '${(percentage * 100).toStringAsFixed(0)}%';

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
                  const Text(
                    'Ngân Sách Dự Kiến',
                    style: TextStyle(
                      color: Color(0xFFFEF3C7),
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
                    child: Text(
                      '$percentageText Đã dùng',
                      style: const TextStyle(
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
                  Text(
                    _formatNumber(totalEstimatedBudget),
                    style: const TextStyle(
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
                  widthFactor: barPercentage,
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
                    'Đã chi: ${_formatNumber(totalActualSpent)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFECACA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Còn lại: ${_formatNumber(remaining)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFECACA),
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

  String _formatNumber(int number) {
    if (number == 0) return '0';
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

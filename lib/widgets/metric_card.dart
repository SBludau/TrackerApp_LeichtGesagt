import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

/// A small card on the Trends dashboard showing the average value for one category.
class MetricCard extends StatelessWidget {
  final Category category;
  final double? value;
  final String subtitle;

  const MetricCard({
    super.key,
    required this.category,
    required this.value,
    this.subtitle = 'Ø diese Woche',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category label
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Value
          Text(
            value != null
                ? value!.toStringAsFixed(1)
                : '—',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: value != null ? category.color : AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

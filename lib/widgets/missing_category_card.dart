import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

/// A purple-tinted card for a category that was not detected in the transcript.
///
/// Offers two quick actions: use the default value or skip this category.
class MissingCategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onUseDefault;
  final VoidCallback onSkip;

  const MissingCategoryCard({
    super.key,
    required this.category,
    required this.onUseDefault,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.missingBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.missingBorder),
      ),
      child: Row(
        children: [
          // Category info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.stress, // purple tint
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Nicht erkannt',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.stress.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                label: 'Standard (${category.defaultValue.toStringAsFixed(0)})',
                onTap: onUseDefault,
                isPrimary: true,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Weglassen',
                onTap: onSkip,
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.missingBorder.withValues(alpha: 0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color:
                isPrimary ? AppColors.missingBorder : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isPrimary ? AppColors.stress : AppColors.textMuted,
            fontWeight:
                isPrimary ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

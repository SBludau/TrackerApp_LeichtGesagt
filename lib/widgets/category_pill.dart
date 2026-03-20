import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

/// A horizontal pill showing a colour dot and the category name.
///
/// [isActive] = true  → indigo border + dark-indigo background (recorded today)
/// [isActive] = false → gray border + surface background (not yet recorded)
class CategoryPill extends StatelessWidget {
  final Category category;

  /// Whether this category has been recorded today.
  final bool isActive;

  const CategoryPill({
    super.key,
    required this.category,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        isActive ? AppColors.indigo : AppColors.border;
    final Color bgColor =
        isActive ? const Color(0xFF1E1F3A) : AppColors.elevatedSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Colour dot
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

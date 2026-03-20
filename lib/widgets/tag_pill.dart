import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small rounded pill used to display a keyword tag.
class TagPill extends StatelessWidget {
  final String label;

  const TagPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFD1D5DB),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

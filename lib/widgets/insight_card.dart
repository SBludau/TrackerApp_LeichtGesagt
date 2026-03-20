import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A green-tinted card that surfaces a positive data insight.
class InsightCard extends StatelessWidget {
  final String label;
  final String text;

  const InsightCard({
    super.key,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.insightBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.insightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF166834),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6EE7B7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

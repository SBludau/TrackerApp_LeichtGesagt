import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

/// A labelled slider for a single category value (1–10).
///
/// Shows:  [color dot]  [category name]  ────────●───────  [value]
class ValueSlider extends StatelessWidget {
  final Category category;
  final double value;
  final ValueChanged<double> onChanged;

  const ValueSlider({
    super.key,
    required this.category,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Label
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: category.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            category.name,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Slider
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: category.color,
              inactiveTrackColor: AppColors.elevatedSurface,
              thumbColor: category.color,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              overlayColor: category.color.withValues(alpha: 0.18),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
        ),
        // Numeric value
        SizedBox(
          width: 32,
          child: Text(
            value.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: category.color,
            ),
          ),
        ),
      ],
    );
  }
}

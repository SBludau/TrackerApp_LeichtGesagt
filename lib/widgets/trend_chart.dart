import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category.dart';
import '../models/daily_entry.dart';
import '../theme/app_theme.dart';

/// A line chart that plots the last 7 days for a single [category].
class TrendChart extends StatelessWidget {
  final Category category;
  final List<DailyEntry> entries;

  const TrendChart({
    super.key,
    required this.category,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart title
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
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: category.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: LineChart(
            _buildChartData(spots),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildSpots() {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 6; i >= 0; i--) {
      final day = DailyEntry.normaliseDate(
          now.subtract(Duration(days: i)));
      final entry = entries.firstWhere(
        (e) => e.date == day,
        orElse: () => DailyEntry(date: day),
      );
      final val = entry.values[category.key];
      if (val != null) {
        spots.add(FlSpot((6 - i).toDouble(), val));
      }
    }
    return spots;
  }

  LineChartData _buildChartData(List<FlSpot> spots) {
    final color = category.color;

    return LineChartData(
      backgroundColor: AppColors.surface,
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 10,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.border,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: 24,
            getTitlesWidget: (value, _) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final idx = value.toInt();
              final day = DateTime.now().subtract(Duration(days: 6 - idx));
              return Text(
                _shortDay(day),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              );
            },
          ),
        ),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        if (spots.isNotEmpty)
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.08),
            ),
          ),
      ],
    );
  }

  String _shortDay(DateTime dt) {
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return days[dt.weekday - 1];
  }
}

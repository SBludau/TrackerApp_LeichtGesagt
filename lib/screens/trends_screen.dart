import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_entry.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/insight_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/tag_pill.dart';
import '../widgets/trend_chart.dart';

/// Screen 3 – Trends & Dashboard.
class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  _DateRange _range = _DateRange.week;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = state.activeCategories;
    final entries = _filteredEntries(state);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: AppSpacing.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trends', style: AppTextStyles.screenTitle),
                  _RangeSelector(
                    current: _range,
                    onChanged: (r) => setState(() => _range = r),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.gap),

              // ── Overview cards ─────────────────────────────────────────
              if (categories.isNotEmpty) ...[
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: categories.map((cat) {
                    final avg = state.averageValue(cat.key, entries);
                    return MetricCard(
                      category: cat,
                      value: avg,
                      subtitle: _rangeLabel(_range),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // ── Trend charts ───────────────────────────────────────────
              if (entries.isNotEmpty) ...[
                const Text('VERLAUF', style: AppTextStyles.sectionHeading),
                const SizedBox(height: 12),
                ...categories.map((cat) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 28),
                      child: Container(
                        padding:
                            const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLarge),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TrendChart(
                          category: cat,
                          entries: entries,
                        ),
                      ),
                    )),
              ],

              // ── Frequent tags ──────────────────────────────────────────
              if (_allTags(entries).isNotEmpty) ...[
                const Text(
                    'HÄUFIGE BEGRIFFE', style: AppTextStyles.sectionHeading),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _allTags(entries)
                      .map((t) => TagPill(label: t))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

              // ── Insights ───────────────────────────────────────────────
              if (_shouldShowInsight(state, entries)) ...[
                const Text('ERKENNTNISSE', style: AppTextStyles.sectionHeading),
                const SizedBox(height: 8),
                InsightCard(
                  label: 'Muster erkannt',
                  text: _insightText(state, entries),
                ),
                const SizedBox(height: 16),
              ],

              // Empty state
              if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        const Icon(Icons.bar_chart_outlined,
                            color: AppColors.textDisabled, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Noch keine Einträge\nfür diesen Zeitraum.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  List<DailyEntry> _filteredEntries(AppState state) {
    switch (_range) {
      case _DateRange.week:
        return state.recentEntries(7);
      case _DateRange.month:
        return state.recentEntries(30);
      case _DateRange.all:
        return state.allEntries
            .where((e) => !e.isSkipped)
            .toList();
    }
  }

  String _rangeLabel(_DateRange r) {
    switch (r) {
      case _DateRange.week:
        return 'Ø diese Woche';
      case _DateRange.month:
        return 'Ø diesen Monat';
      case _DateRange.all:
        return 'Ø gesamt';
    }
  }

  List<String> _allTags(List<DailyEntry> entries) {
    final freq = <String, int>{};
    for (final e in entries) {
      for (final tag in e.tags) {
        freq[tag] = (freq[tag] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(10).map((e) => e.key).toList();
  }

  bool _shouldShowInsight(AppState state, List<DailyEntry> entries) {
    if (entries.length < 3) return false;
    return true;
  }

  String _insightText(AppState state, List<DailyEntry> entries) {
    // Mock insight: check if sleep correlates with energy
    final sleepEntries =
        entries.where((e) => e.values.containsKey('schlaf')).toList();
    final energyEntries =
        entries.where((e) => e.values.containsKey('energie')).toList();

    if (sleepEntries.isNotEmpty && energyEntries.isNotEmpty) {
      final goodSleepEntries = sleepEntries
          .where((e) => (e.values['schlaf'] ?? 0) >= 7)
          .toList();
      if (goodSleepEntries.isNotEmpty) {
        double avgEnergySleep = 0;
        int count = 0;
        for (final e in goodSleepEntries) {
          if (e.values.containsKey('energie')) {
            avgEnergySleep += e.values['energie']!;
            count++;
          }
        }
        if (count > 0) {
          avgEnergySleep /= count;
          return 'An Tagen mit gutem Schlaf (≥7) ist deine Energie im Schnitt '
              'bei ${avgEnergySleep.toStringAsFixed(1)} — halte guten Schlaf aufrecht!';
        }
      }
    }

    // Fallback insight
    final stressVals = entries
        .where((e) => e.values.containsKey('stress'))
        .map((e) => e.values['stress']!)
        .toList();
    if (stressVals.isNotEmpty) {
      final avg = stressVals.reduce((a, b) => a + b) / stressVals.length;
      if (avg > 6) {
        return 'Dein durchschnittliches Stresslevel liegt bei '
            '${avg.toStringAsFixed(1)}. Achte auf Erholungsphasen.';
      }
    }
    return 'Du trackst regelmäßig – weiter so! Trends werden sichtbar, '
        'sobald mehr Einträge vorhanden sind.';
  }
}

// ─── Date range enum & selector ───────────────────────────────────────────────

enum _DateRange { week, month, all }

class _RangeSelector extends StatelessWidget {
  final _DateRange current;
  final ValueChanged<_DateRange> onChanged;

  const _RangeSelector({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _DateRange.values.map((r) {
        final isSelected = r == current;
        return GestureDetector(
          onTap: () => onChanged(r),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.indigo.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color:
                    isSelected ? AppColors.indigo : AppColors.border,
              ),
            ),
            child: Text(
              _label(r),
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.indigo
                    : AppColors.textMuted,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(_DateRange r) {
    switch (r) {
      case _DateRange.week:
        return 'Woche';
      case _DateRange.month:
        return 'Monat';
      case _DateRange.all:
        return 'Alles';
    }
  }
}

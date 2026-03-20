import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_entry.dart';
import '../models/extraction_result.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/tag_pill.dart';
import '../widgets/value_slider.dart';

/// Screen 2 – Review & Validierung.
///
/// Zeigt IMMER Slider für alle aktiven Kategorien.
/// Erkannte Werte werden vorbelegt; nicht erkannte Kategorien werden mit dem
/// jeweiligen Standardwert vorbelegt und visuell markiert.
class ReviewScreen extends StatefulWidget {
  final String transcript;
  final ExtractionResult extractionResult;

  const ReviewScreen({
    super.key,
    required this.transcript,
    required this.extractionResult,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  /// Aktuelle Slider-Werte (immer befüllt — extracted oder default).
  late final Map<String, double> _values;

  /// Kategorien für die der NLP keinen Wert gefunden hat.
  late final Set<String> _autoFilledKeys;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();

    _values = {};
    _autoFilledKeys = {};

    for (final cat in state.activeCategories) {
      if (widget.extractionResult.values.containsKey(cat.key)) {
        _values[cat.key] = widget.extractionResult.values[cat.key]!;
      } else {
        // Nicht erkannt → Standardwert vorbelegen, als "auto-filled" markieren
        _values[cat.key] = cat.defaultValue;
        _autoFilledKeys.add(cat.key);
      }
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final state = context.read<AppState>();
    final entry = DailyEntry(
      date: DailyEntry.normaliseDate(DateTime.now()),
      values: Map<String, double>.from(_values),
      tags: widget.extractionResult.tags,
      transcript: widget.transcript,
    );
    await state.saveEntry(entry);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeCategories = state.activeCategories;
    final extractedCount = activeCategories
        .where((c) => !_autoFilledKeys.contains(c.key))
        .length;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textSecondary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Überprüfen', style: AppTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Transcript ───────────────────────────────────────────────
              const Text('ERKANNTER TEXT', style: AppTextStyles.sectionHeading),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(widget.transcript, style: AppTextStyles.body),
              ),

              const SizedBox(height: 20),

              // ── Extraction summary hint ───────────────────────────────────
              Row(
                children: [
                  const Text('WERTE', style: AppTextStyles.sectionHeading),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: extractedCount > 0
                          ? AppColors.insightBg
                          : AppColors.missingBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: extractedCount > 0
                            ? AppColors.insightBorder
                            : AppColors.missingBorder,
                      ),
                    ),
                    child: Text(
                      extractedCount > 0
                          ? '$extractedCount von ${activeCategories.length} erkannt'
                          : 'Keine Werte erkannt – Standardwerte vorbelegt',
                      style: TextStyle(
                        fontSize: 10,
                        color: extractedCount > 0
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFFa78bfa),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Sliders – IMMER für alle Kategorien ──────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: activeCategories.map((cat) {
                    final isAutoFilled = _autoFilledKeys.contains(cat.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAutoFilled)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 2, bottom: 3),
                              child: Text(
                                'nicht erkannt – Standardwert',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textDisabled
                                      .withValues(alpha: 0.7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ValueSlider(
                            category: cat,
                            value: _values[cat.key]!,
                            onChanged: (v) {
                              setState(() {
                                _values[cat.key] = v;
                                // Sobald der Nutzer anpasst, ist es kein Auto-fill mehr
                                _autoFilledKeys.remove(cat.key);
                              });
                            },
                            dimmed: isAutoFilled,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Tags ─────────────────────────────────────────────────────
              if (widget.extractionResult.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('ERKANNTE BEGRIFFE',
                    style: AppTextStyles.sectionHeading),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.extractionResult.tags
                      .map((t) => TagPill(label: t))
                      .toList(),
                ),
              ],

              const SizedBox(height: 32),

              // ── Save button ───────────────────────────────────────────────
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.indigo,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: const Center(
                    child: Text('Speichern',
                        style: AppTextStyles.buttonPrimary),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Re-record button ──────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Neu aufnehmen',
                        style: AppTextStyles.buttonSecondary),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

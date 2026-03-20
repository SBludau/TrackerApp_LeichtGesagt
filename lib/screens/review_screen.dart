import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/daily_entry.dart';
import '../models/extraction_result.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/missing_category_card.dart';
import '../widgets/tag_pill.dart';
import '../widgets/value_slider.dart';

/// Screen 2 – Review & Validierung.
///
/// Shows the extracted category values, allows adjustment, handles missing
/// categories, and saves the final [DailyEntry].
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
  late final Map<String, double> _values;
  final Set<String> _skippedCategories = {};

  @override
  void initState() {
    super.initState();
    _values = Map<String, double>.from(widget.extractionResult.values);
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void _applyDefault(CategoryType type) {
    final state = context.read<AppState>();
    final cat = state.activeCategories
        .firstWhere((c) => c.type == type, orElse: () => Category(type: type));
    setState(() {
      _values[type.key] = cat.defaultValue;
      _skippedCategories.remove(type.key);
    });
  }

  void _skipCategory(CategoryType type) {
    setState(() {
      _values.remove(type.key);
      _skippedCategories.add(type.key);
    });
  }

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

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeCategories = state.activeCategories;

    // Categories for which we have values
    final recordedCategories = activeCategories
        .where((c) => _values.containsKey(c.key))
        .toList();

    // Missing categories (not in values AND not explicitly skipped)
    final missingTypes = widget.extractionResult.missingCategories
        .where((t) => !_skippedCategories.contains(t.key))
        .toList();

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
        title: const Text('Überprüfen',
            style: AppTextStyles.screenTitle),
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
              // ── Transcript ─────────────────────────────────────────────
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
                child: Text(
                  widget.transcript,
                  style: AppTextStyles.body,
                ),
              ),

              // ── Extracted values ───────────────────────────────────────
              if (recordedCategories.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                    'ERKANNTE WERTE', style: AppTextStyles.sectionHeading),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: recordedCategories
                        .map((cat) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6),
                              child: ValueSlider(
                                category: cat,
                                value: _values[cat.key]!,
                                onChanged: (v) => setState(
                                    () => _values[cat.key] = v),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],

              // ── Missing categories ─────────────────────────────────────
              if (missingTypes.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'FEHLENDE KATEGORIEN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C3AED),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                ...missingTypes.map((type) {
                  final cat = activeCategories.firstWhere(
                    (c) => c.type == type,
                    orElse: () => Category(type: type),
                  );
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.gapTight),
                    child: MissingCategoryCard(
                      category: cat,
                      onUseDefault: () => _applyDefault(type),
                      onSkip: () => _skipCategory(type),
                    ),
                  );
                }),
              ],

              // ── Tags ───────────────────────────────────────────────────
              if (widget.extractionResult.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                    'ERKANNTE BEGRIFFE', style: AppTextStyles.sectionHeading),
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

              // ── Save button ────────────────────────────────────────────
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
                    child:
                        Text('Speichern', style: AppTextStyles.buttonPrimary),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Re-record button ───────────────────────────────────────
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
                    child: Text(
                      'Neu aufnehmen',
                      style: AppTextStyles.buttonSecondary,
                    ),
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

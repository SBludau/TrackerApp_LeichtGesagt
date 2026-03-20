import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../services/preferences_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

/// Screen 0 – shown only on first launch.
///
/// Lets the user choose which categories they want to track (minimum 2).
/// Saves the selection to [PreferencesService] and marks onboarding as done.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<CategoryType> _selected = {
    CategoryType.stress,
    CategoryType.energie,
  };

  bool get _canProceed => _selected.length >= 2;

  void _toggleCategory(CategoryType type) {
    setState(() {
      if (_selected.contains(type)) {
        if (_selected.length > 2) _selected.remove(type);
      } else {
        _selected.add(type);
      }
    });
  }

  void _applyPreset(List<CategoryType> types) {
    setState(() {
      _selected
        ..clear()
        ..addAll(types);
    });
  }

  Future<void> _loslegen() async {
    if (!_canProceed) return;

    final prefs = PreferencesService();
    await prefs.setActiveCategories(_selected.toList());
    await prefs.setOnboardingCompleted(true);

    if (!mounted) return;
    await context.read<AppState>().setActiveCategories(_selected.toList());

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 16),
              // Logo + title
              Center(
                child: Column(
                  children: [
                    const AppLogo(size: 56),
                    const SizedBox(height: 16),
                    const Text('LeichtGesagt',
                        style: AppTextStyles.screenTitle),
                    const SizedBox(height: 6),
                    Text(
                      'Dein Sprachtagebuch',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Section heading
              const Text(
                'WÄHLE DEINE KATEGORIEN (3–4)',
                style: AppTextStyles.sectionHeading,
              ),
              const SizedBox(height: 12),

              // Category cards
              ...CategoryType.values.map((type) => _CategoryCard(
                    type: type,
                    isSelected: _selected.contains(type),
                    onTap: () => _toggleCategory(type),
                  )),

              const SizedBox(height: 24),

              // Pre-selected profiles
              const Text(
                'SCHNELLAUSWAHL',
                style: AppTextStyles.sectionHeading,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PresetButton(
                      label: 'Stress & Energie',
                      onTap: () => _applyPreset([
                        CategoryType.stress,
                        CategoryType.energie,
                      ]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PresetButton(
                      label: 'Vollständig',
                      onTap: () => _applyPreset(CategoryType.values),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Explanation
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Für jede Kategorie wird ein Standardwert von 5 verwendet, '
                  'wenn du nichts anderes angibst.',
                  style: AppTextStyles.body,
                ),
              ),

              const SizedBox(height: 32),

              // CTA
              GestureDetector(
                onTap: _canProceed ? _loslegen : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _canProceed
                        ? AppColors.indigo
                        : AppColors.indigo.withValues(alpha: 0.35),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: const Center(
                    child: Text('Loslegen', style: AppTextStyles.buttonPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.gapTight),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? type.color.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: isSelected ? type.color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(type.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? type.color
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    type.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? type.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? type.color : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Preset Button ────────────────────────────────────────────────────────────

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface,
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
